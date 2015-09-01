# This is annoying, but pandoc (document conversion) is fairly impossible to
# install on a locked down system.  The main solution seems to be installing
# a mostly statically linked binary and then adding LD_LIBRARY_PATH for the
# few shared library files like libffi.so.5 that are missing.

# if it's x86_64-linux then load up LD
if (/x86_64-linux/ =~ RUBY_PLATFORM) != nil
  # export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/dmp2/local/lib64
  add_path = APP_CONFIG['ld_path_for_pandoc']
  if ENV['LD_LIBRARY_PATH'].nil?
    ENV['LD_LIBRARY_PATH'] = add_path
  elsif !ENV['LD_LIBRARY_PATH'].include?(add_path)
    ENV['LD_LIBRARY_PATH'] = "#{ENV['LD_LIBRARY_PATH']}:#{add_path}"
  end
end