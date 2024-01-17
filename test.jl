using Random
function seq_sum(arr)
    total = 0
    for el in arr
        total += el
    end
    return total
end
function th_sum(arr,num_th)
    len = length(arr)
    chunck_size = div(len,num_th)
    partial_sum = zeros(Int,num_th)
    @sync begin
        for i in eachindex(partial_sum)
            start_ind = (i-1)*chunck_size +1
            end_ind = i==num_th ? len : i*chunck_size
            Threads.@spawn partial_sum[i] = sum(view(arr,start_ind:end_ind))
        end
    end
    total = sum(partial_sum)
    return total
end
function main(num_thread)
    Random.seed!(123)
    seq_sum(collect(1:10))
    th_sum(collect(1:10),num_thread)
    arr = rand(1:100,1_000_000_000)
    @info "seq sum"
    times = Float64[]
    r=0
    for _ in 1:20
        t =time_ns()
        r = seq_sum(arr)
        push!(times,1e-9*(time_ns()-t))
    end
    @info "result = $r, time = $(sum(times)/20)"
    @info "th sum"
    times = Float64[]
    r = 0
    for _ in 1:20
        t =time_ns()
        r = th_sum(arr,num_thread)
        push!(times,1e-9*(time_ns()-t))
    end
    @info "result = $r, time = $(sum(times)/20)"
end

@info "4 THREADS"
main(4)

