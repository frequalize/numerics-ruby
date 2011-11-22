def clean
  Dir['numerics-*.gem'].each{|f| File.unlink(f)}
end

def build
  `gem build numerics.gemspec`
end

def publish_local
  dir = '~/Development/Gems/'
  `cp numerics-*.gem #{dir}/gems/`
  `gem generate_index --update --modern -d #{dir}`
end

def publish_remote
  `gem push numerics-*.gem --key frequalize`
end

def uninstall
  `gem uninstall numerics`
end

def install_local
  do_install('http://localhost/Gems/')
end

def install_remote
  do_install
end

def do_install(source=nil)
  cmd = 'gem install numerics'
  if !source.nil?
    cmd << " --source #{source}"
  end
  `#{cmd}`
end

def run_tests(gem=true)
  cmd = "ruby test/all"
  if gem 
    cmd << ' gem'
  end
  puts `#{cmd}`
end

def test
  clean
  uninstall
  build
  publish_local
  install_local
  run_tests
end

def publish
  clean
  uninstall
  build
  publish_remote
  install_remote
  run_tests
end

namespace :gem do 
  task(:clean){clean}
  task(:build){build}
  task(:uninstall){uninstall}
  task(:install_local){install_local}
  task(:install_remote){install_remote}
  task(:publish_local){publish_local}
  task(:publish_remote){publish_remote}
  task(:run_tests){run_tests}
  task(:test){test}
  task(:publish){publish}
end
