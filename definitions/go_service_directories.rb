define :go_service_directories do
	user = params[:user]
	group = params[:group]
	deploy_to = params[:deploy_to]

	directory "#{deploy_to}/shared" do
		group group
		owner user
		mode 0774
		action :create
		recursive true
	end

  # create shared/ directory structure
	['log','config','system','pids','scripts','sockets'].each do |dir_name|
		directory "#{deploy_to}/shared/#{dir_name}" do
		group group
		owner user
		mode 0774
		action :create
		recursive true
		end
	end

end
