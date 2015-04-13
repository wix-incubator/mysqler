return unless node['mysqler'][:handle_backward_compatibility]==true

bindir = node['mysqler'][:backward_compatibility][:basedir]+"/bin/"
sharedir = node['mysqler'][:backward_compatibility][:basedir]+"/share/"

directory bindir do
  recursive true
end

ruby_block "link-all-binaries" do
  block do 
    get_binaries=Mixlib::ShellOut.new("dpkg -L #{node['mysqler'][:backward_compatibility][:new_package]} | grep '/bin/'")
    get_binaries.run_command
    get_binaries.error!
    binaries = get_binaries.stdout.lines.map(&:chomp)
    FileUtils.ln(binaries, bindir) rescue Errno::EEXIST
  end
end

directory sharedir do
  recursive true
end

ruby_block "link-share" do
  block do 
    get_share=Mixlib::ShellOut.new("dpkg -L #{node['mysqler'][:backward_compatibility][:new_package]} | grep '/share/mysql$'")
    get_share.run_command
    get_share.error!
    share = get_share.stdout.lines.map(&:chomp)
    FileUtils.ln_s(share, sharedir) rescue Errno::EEXIST
  end
end

