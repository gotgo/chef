define :go_service_build do
	deploy = params[:service_settings]
	deploy_key = params[:deploy_key]

	if deploy_key.to_s.empty?
		#for testing?
		deploy_key =  IO.read("/opt/deploy_keys/deploy_#{app_name}")
	end

	go_main_dir = deploy[:go_main_dir] 
	deploy_to = deploy[:deploy_to]
	if deploy_to.to_s.empty?
		deploy_to = '/opt'
	end

	new_release_dir = Time.now.strftime("%Y-%m-%dT%H%M-%S")
	releases_dir = "#{deploy_to}/releases"
	go_path = "#{releases_dir}/#{new_release_dir}"
	repo = deploy[:repository]

	go_repository = deploy[:go_repository]
	if go_repository.to_s.empty? 
		#private syntax git@github.com:root/repot.git
		if match = repo.gsub(/[-a-zA-Z0-9]+@([a-zA-Z0-9-]+[.][a-zA-Z]+):([-a-zA-Z0-9\/]+)/, '\1/\2')
			go_repository = match
		# public syntax https://github.com/root/repot
		elsif match = repo.gsub(/https:\/\/([-a-zA-Z0-9]+[.][a-zA-Z]+\/[-a-zA-Z0-9\/]+)/, '\1')
			go_repository = match
		end
	end

	branch_name = deploy[:branch]

	#create go root
	directory "#{go_path}" do
		group deploy[:group]
		owner deploy[:user]
		mode "0775"
		action :create
		recursive true
	end

	#go base dirs
	['src','bin','pkg'].each do |dir_name|
		directory "#{go_path}/#{dir_name}" do
			group deploy[:group]
			owner deploy[:user]
			mode "0775"
			action :create
			recursive true
		end
	end

	ensure_scm_package_installed('git')

	home = deploy[:home]

	ruby_block "change HOME to #{deploy[:home]} for source checkout" do
		block do
		ENV['HOME'] = home
		end
	end
	
	#running as root here
	#so we can checkout private repos
	execute 'git config --global url."git@github.com:".insteadOf "https://github.com/"' do
		user 'root'
		group 'root'
		#environment( { "HOME" => home })
	end

#	#so we can checkout private repos
#	execute 'git config --global url."git@github.com:".insteadOf "https://github.com/"' do
#		user deploy[:user]
#		group deploy[:group]
#	end

    prepare_git_checkouts(
      :user => deploy[:user],
      :group => deploy[:group],
      :home => home,
      :ssh_key => deploy_key
    ) 

	parts = go_repository.split("/")
	prev = "#{go_path}/src" 
	#we have to do this retarded thing because the owner and group only apply to 
	#leaf nodes on creating a recursive structure
	parts.each do |dir_name| 
		current = "#{prev}/#{dir_name}" 
		directory current do
			group deploy[:group]
			owner deploy[:user]
			mode "0775"
			action :create
			recursive false
		end
		prev = current
	end
	checkout_to =  "#{go_path}/src/#{go_repository}"

	#go source
	directory "#{checkout_to}" do
		group deploy[:group]
		owner deploy[:user]
		mode "0775"
		action :create
		recursive true
	end
	
	git "#{checkout_to}"  do
		repository "#{deploy[:repository]}"	
		revision branch_name
		action :sync
		#envirnoment not supported by opsworks
		#environment "HOME" => deploy[:home] 
		user deploy[:user]
		group deploy[:group]
	end

	main_dir = checkout_to
	if !go_main_dir.to_s.empty?
		main_dir = "#{checkout_to}/#{go_main_dir}"
	end

	execute '/usr/local/go/bin/go get' do 
		cwd main_dir
		environment ({
			'GOPATH' => "#{go_path}",
			'GOBIN' => "#{go_path}/bin"
		})
		user  deploy[:user]
		group deploy[:group]
		ignore_failure true
	end

	execute '/usr/local/go/bin/go install' do 
		cwd main_dir
		environment ({
			'GOPATH' => "#{go_path}",
			'GOBIN' => "#{go_path}/bin"
		})
		user deploy[:user]
		group deploy[:group]
	end

	#be good to also run ginkgo tests
	#coverage also
	
	link "#{deploy_to}/current" do
		to "#{go_path}/"
		owner deploy[:user]
		group deploy[:group]
	end

	go_service_clean_old do
		releases_dir releases_dir
	end

#	ruby_block "change HOME back to /root after source checkout" do
#		block do
#		ENV['HOME'] = "/root"
#		end
#	end	

end
