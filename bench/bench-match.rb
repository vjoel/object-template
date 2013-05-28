$LOAD_PATH.unshift File.join(__dir__, "lib")

require 'bench'
require 'object-template'

ROT = RubyObjectTemplate
POT = PortableObjectTemplate

SEED = 1237

def make_dataset
  strs = ("a".."z").map {|c| "fo" + c}
  (1..1000).map {|i| [ i, strs.sample, rand(50) ]}
end

def run_bench_on_template template, seed: nil
  srand seed
  objs = make_dataset

  matched = 0
  rslt = bench_rate n_sec: 1.0, notify: proc {|c| print c} do
    matched += 1 if template === objs.sample
  end

  puts
  puts "seed     = %8d" % seed
  puts "matched  = %8d" % matched
  puts "n_iter   = %8d" % rslt[:n_iter]
  puts "n_chunk  = %8d" % rslt[:n_chunk]
  puts "t_warmup = %12.3f sec" % rslt[:t_warmup]
  puts "t_run    = %12.3f sec" % rslt[:t_run]
  puts "rate     = %12.3f iter/sec" % rslt[:rate]
  
  rslt
end

template = POT.new [ {set: [0,1,2,*100..999]}, {regex: "foo"}, {value: 0} ]
puts "Unoptimized:"
r0 = run_bench_on_template template, seed: SEED

puts
puts "Optimized:"
template.optimize!
r1 = run_bench_on_template template, seed: SEED

puts
puts "Speed-up: %5.2f" % (r1[:rate] / r0[:rate])
