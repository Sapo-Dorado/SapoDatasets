#This object combines all of the elements required to train a model and trains it
mutable struct Trainer
    data
    model
    loss
    opt
    ps
    cbs
end

function Trainer(data, model, loss, opt=ADAM(), cbs=()->())
    Trainer(data, model, loss, opt, params(model), cbs)
end

#equivalent to Flux's train! function with different inputs
function fit(trainer::Trainer, epochs::Int)
    cb = runall(trainer.cbs)
    for i in 1:epochs
        for b in trainer.data
            try
                gs = [get_gradient(trainer.loss, d, trainer.ps) for d in b]
                update_avg!(trainer.opt, trainer.ps, gs)
                cb()
            catch ex
                if ex isa StopException
                    break
                else
                    rethrow(ex)
                end
            end
        end
    end
end

function fit_one_cycle(trainer::Trainer, epochs::Int)
    trainer.cbs = [trainer.cbs..., one_cycle_cb(trainer, epochs)]
    fit(trainer, epochs)
end

#returns the model's prediction for a given input
function predict(trainer::Trainer, vals)
    return trainer.model(vals)
end

function get_gradient(loss, args, ps)
    Flux.Tracker.gradient(ps) do
        loss(args...)
    end
end

function update_avg!(opt, ps, gs)
    for x in ps
        sum = gs[1][x]
        for g in gs[2:end]
            sum += g[x]
        end
        Flux.Tracker.update!(opt, x, sum / length(gs))
    end
end
            
            
    
#from Flux's train.jl
call(f, xs...) = f(xs...)
runall(f) = f
runall(fs::AbstractVector) = () -> foreach(call, fs)

struct StopException <: Exception end

function stop()
  throw(StopException())
end

