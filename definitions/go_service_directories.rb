define :go_service_directories do
	user = params[:user]
	group = params[:group]
	conf_link_dir = params[:conf_link_dir]

	deploy_root= "#{params[:deploy_to]}/#{params[:service_name]}"

	directory "#{deploy_root}" do
		group group
		owner user
		mode 0774
		action :create
		recursive true
	end

	directory "#{deploy_root}/shared" do
		group group
		owner user
		mode 0774
		action :create
		recursive true
	end

  # create shared/ directory structure
	['log','config','system','pids','scripts','sockets'].each do |dir_name|
		directory "#{deploy_root}/shared/#{dir_name}" do
		group group
		owner user
		mode 0774
		action :create
		recursive true
		end
	end

	# link shared config to /etc/{servicename}
	config_dir = "#{deploy_root}/shared/config"
	config_dir_link_to = "#{conf_link_dir}/#{service_name}"

	link config_dir_link_to do
		to "#{config_dir}/"
	end

end
