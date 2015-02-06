define :go_service_user do
	user = params[:user]
	group = params[:group]
	shell = params[:shell]
	home = params[:home]

	group group

	user user do
		action :create
		comment "created by chef user"
		gid group
		home home
	#	supports :manage_home => true
		shell shell
	#	not_if do
	#		existing_usernames = []
	#		Etc.passwd {|currentuser| existing_usernames << currentuser['name']}
	#		existing_usernames.include?(user)
	#	end
	end
end
