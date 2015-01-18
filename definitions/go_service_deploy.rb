
define :go_service_deploy do
	settings params[:deploy_settings]
	deploy_key params[:deploy_key]

	service_name = settings[:service_name]
	user = settings[:user]
	group = settings[:group]
	shell = settings[:shell]
	home = settings[:home]
	deploy_to = settings[:deploy_to]

	user = service_name unless !user.to_s.empty?
	group = user unless !group.to_s.empty?
	deploy_to = '/opt' unless !deploy_to.to_s.empty?

	kn_deploy_user do
		user user
		group group
		shell shell
		home home
	end

	kn_deploy_app_dir do
		user user
		group group
		path deploy_to
	end

	kn_go_build do
		service_settings settings
		deploy_key deploy_key
	end
end

