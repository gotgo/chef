
define :go_service_deploy do
	settings	= params[:settings]
	key			= params[:key]

	service_name = settings[:service_name]
	user = settings[:user]
	group = settings[:group]
	shell = settings[:shell]
	home = settings[:home]
	deploy_to = settings[:deploy_to]
	conf_link_dir = settings[:conf_link_dir]

	user = service_name unless !user.to_s.empty?
	group = user unless !group.to_s.empty?
	deploy_to = '/opt' unless !deploy_to.to_s.empty?
	home = "/home/#{user}" unless !home.to_s.empty?
	conf_link_dir = "/etc" unless !conf_link_dir.to_s.empty?

	go_service_user do
		user user
		group group
		shell shell
		home home
	end

	go_service_directories do
		user user
		group group
		deploy_to deploy_to
		service_name service_name
		conf_link_dir conf_link_dir
	end

	go_service_build do
		service_settings settings
		deploy_key key
	end
end

