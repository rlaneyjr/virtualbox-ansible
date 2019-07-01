require 'spec_helper'

describe "Virtualbox host setup" do
  virtualbox_user = ANSIBLE_VARS.fetch('virtualbox_user', 'FAIL')

  describe package("virtualbox-#{ANSIBLE_VARS.fetch('virtualbox_version', 'UNKNOWN')}") do
    it { should be_installed }
  end

  describe package('apache2') do
    it { should be_installed }
  end

  describe file('/var/www/html/') do
    it { should be_directory }
  end

  describe package('php5') do
    it { should be_installed }
  end

  describe package('unzip') do
    it { should be_installed }
  end

  describe user(virtualbox_user) do
    it { should exist }
    it { should have_home_directory("/home/#{virtualbox_user}") }
    it { should belong_to_group('vboxusers') }
    it { should have_login_shell('bin/bash') }
  end

  describe file("/home/#{virtualbox_user}/isos") do
    it { should be_directory }
    it { should be_owned_by(virtualbox_user) }
  end

  describe file('/var/www/html/config.php') do
    its(:content) { should include("var $username = '#{virtualbox_user}';") }
    its(:content) { should include("var $password = '#{ANSIBLE_VARS.fetch('virtualbox_user_pw', 'fail')}';") }
    its(:content) { should include("var $password = '#{ANSIBLE_VARS.fetch('virtualbox_user_pw', 'fail')}';") }
    its(:content) { should include("var $browserRestrictFolders = array('/home/#{virtualbox_user}/isos');") }
  end

  describe file('/var/www/html/index.html') do
    it { should exist }
    its(:content) { should include('<title>phpVirtualBox - VirtualBox Web Console</title>') }
  end

  describe file('/etc/default/virtualbox') do
    it { should exist }
    its(:content) { should include("VBOXWEB_USER=#{virtualbox_user}") }
  end

  describe service('vboxweb-service') do
    it { should be_enabled }
    it { should be_running }
  end

  describe service('apache2') do
    it { should be_enabled }
    it { should be_running }
  end
end
