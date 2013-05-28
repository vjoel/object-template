def bench
  times = Process.times
  t0 = times.utime + times.stime

  yield

  times = Process.times
  t1 = times.utime + times.stime
  t1 - t0
end

def bench_rate n_sec: 1.0, n_chunk: 1, notify: nil
  times = Process.times
  t_init = times.utime + times.stime
  #puts "init at #{t_init}"

  t_run = 0
  n_iter = 0
  t_now = nil
  t_start = nil

  while t_run < n_sec
    n_chunk.times do
      yield
    end
    
    times = Process.times
    t_now = times.utime + times.stime
      
    if t_now - t_init < n_sec/4.0 # warm up and seek stride
      n_chunk *= 2
      #puts "n_chunk = #{n_chunk}"
      notify and notify.call "."
    else
      if not t_start
        t_start = t_now
        #puts "start at #{t_start}"
      end
      
      notify and notify.call "0"
      
      n_iter += n_chunk
      t_run = t_now - t_start
    end
  end

  {
    n_iter: n_iter,
    t_warmup: t_start - t_init,
    t_run: t_run,
    rate: n_iter / t_run.to_f,
    n_chunk: n_chunk
  }
end

