# Set a custom session root path. Default is `$HOME`.
# Must be called before `initialize_session`.
session_root "~/projects/wcpay"

# Create session with specified name if it does not already exist. If no
# argument is given, session name will be based on layout file name.
if initialize_session "wcpay-dev"; then

	clientdir="woocommerce-payments"
	serverdir="woocommerce-payments-server"

	run_cmd "open /Applications/Docker.app"

	# Background processes window
	new_window "Background Processes"
	run_cmd "cd $clientdir && nvm use && npm run dev"
	split_h 50
	run_cmd "cd $serverdir && nvm use && npm run start"
	split_v 50
	run_cmd "cd $serverdir && npm run sync" 

	# Client Environment Window
	new_window "Client"
	run_cmd "cd $clientdir && nvim ."
	split_v "10"
	run_cmd "cd $clientdir && less +F docker/wordpress/wp-content/debug.log" 

	# Server Environment Window
	new_window "Server"
	run_cmd "cd $serverdir && nvim ."
	split_v "10"
	run_cmd "cd $serverdir && less +F logstash.log" 
	split_h 
	run_cmd "cd $serverdir && nvim ."

# Finalize session creation and switch/attach to it.
finalize_and_go_to_session
