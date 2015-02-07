define :go_service_user do
	user = params[:user]
	group = params[:group]
	shell = params[:shell]
	home = params[:home]

	home = "/home/#{user}" unless !home.to_s.empty?
	shell = "/bin/bash" unless !shell.to_s.empty?

	group group

	user user do
		action :create
		comment "created by chef user"
		gid group
		home home
		supports :manage_home => true
		system true
		shell shell
	end
end
