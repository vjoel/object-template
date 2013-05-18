$LOAD_PATH.unshift File.join(__dir__, "lib")

require 'bench'
require 'object-template'

ROT = RubyObjectTemplate
POT = PortableObjectTemplate

SEED = 1237

def dataset_for seed
  srand seed
  strs = ("a".."z").map {|c| "fo" + c}
  objs = (1..1000).map {[ strs.sample, rand(50) ]}
  {seed: seed, objs: objs}
end

def run_bench_on_template template, seed: nil, objs: nil
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
end

template = POT.new [ {regex: "foo"}, {value: 0} ]
run_bench_on_template template, dataset_for(SEED)

template.optimize!
run_bench_on_template template, dataset_for(SEED)
