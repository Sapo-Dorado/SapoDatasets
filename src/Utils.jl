#changes the size of the images accesed by the list
transform(list, newSize::Int) = list.size = newSize 

function one_cycle_cb(trainer::Trainer, epochs::Int, max_lr, moms)
    total_steps = length(trainer.data) * epochs
    phase1_steps = floor(total_steps / 2)
    phase2_steps = total_steps - phase1_steps
    current_step = 0
    opt = trainer.opt
    min_lr = max_lr / 25
    opt.eta = min_lr
    forward_lr_stepper, backward_lr_stepper = (linear_step(min_lr, max_lr), linear_step(max_lr, min_lr))
    has_momentum = :rho in fieldnames(typeof(opt))
    forward_mom_stepper, backward_mom_stepper = has_momentum ?
            (linear_step(moms[1], moms[2]), linear_step(moms[2], moms[1])) : (nothing, nothing)
    () -> begin
            current_step += 1
            step_pct = current_step <= phase1_steps ? current_step / phase1_steps : (current_step - phase1_steps) / phase2_steps 
            opt.eta = current_step <= phase1_steps ? 
                    forward_lr_stepper(step_pct) :
                    backward_lr_stepper(step_pct)
            if has_momentum
                opt.rho = current_step <= phase1_steps ?
                        forward_mom_stepper(step_pct) :
                        backward_mom_stepper(step_pct)
            end
          end 
end
    

function linear_step(first, last)
    difference = last - first
    (pct) -> first + (difference * pct)
end
