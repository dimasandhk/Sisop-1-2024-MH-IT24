#!/bin/bash

echo "Welcome to Login System"
echo "1. Login"
echo "2. Forgot Password"

read pil

forgot_pw() {
	echo -n "Enter your email: "
	read email

	# email,username,question,answer,
	info_pw=$(awk -v email="$email" -F ',' '$1 == email {print $5}' users/users.txt)
	question=$(awk -v email="$email" -F ',' '$1 == email {print $3}' users/users.txt)
	answer=$(awk -v email="$email" -F ',' '$1 == email {print $4}' users/users.txt)
	if [ "$info_pw" ]; then
		echo "$question: "
		read answ_inp
		if [ "$answ_inp" == "$answer" ]; then
			echo "Your password is: $(echo "$info_pw" | base64 -d)"
		else
			echo "Your security answer is wrong!"
		fi
	else
		echo "Email not found!"
	fi
}

delete_user() {
	echo "Enter your email: "
	read del_email

	user_found=$(awk -F ',' -v email="$del_email" '$1 == email {print $2}' users/users.txt)
	if [ "$user_found" ]; then
		sed -i "/^$del_email,/d" "users/users.txt"
	else
		echo "User not found."
	fi
}

add_user() {
	echo -n "Enter your email: "
	read email
	echo -n "Enter your username: "
	read username
	echo -n "Enter a security question: "
	read question
	echo -n "Enter the answer to your security question: "
	read question_answer
	echo "Enter a password"
	echo "(Must be containing >= 8 char, at least 1 lowercase & uppercase letter, and at least 1 number): "
	read -s password

	encrypted_pass=$(echo -n "$password" | base64)

	if grep -q "$email" users/users.txt; then
		echo "Email already exists!"
		echo "$(date +"%Y/%m/%d %H:%M:%S") REGISTER FAILED user $username failed to register" >> users/auth.log
	else
		if [[ ${#password} -lt 8 || !("$password" =~ [A-Z]) || !("$password" =~ [a-z]) || !("$password" =~ [0-9]) ]]; then
			echo "Your password does not meet security requirements!"
			echo "$(date +"%Y/%m/%d %H:%M:%S") REGISTER FAILED user $username failed to register" >> users/auth.log
		else
			mkdir -p "users"

			echo "Registered successfully!"
			echo "$email,$username,$question,$question_answer,$encrypted_pass" >> users/users.txt
			echo "$(date +"%Y/%m/%d %H:%M:%S") REGISTER SUCCESS user $username registered successfully" >> users/auth.log
		fi
	fi	
}

edit_user() {
	echo "Enter your email: "
	read del_email

	user_found=$(awk -F ',' -v email="$del_email" '$1 == email {print $1, $2, $3, $4}' users/users.txt)
	info_pw=$(awk -v email="$email" -F ',' '$1 == email {print $5}' users/users.txt)
	echo "This is your past account info $user_found, $(echo "$info_pw" | base64 -d)"
	if [ "$user_found" ]; then
		sed -i "/^$del_email,/d" "users/users.txt"
	else
		echo "User not found."
	fi	

	add_user
}

login() {
	echo -n "Enter your email: "
	read email
	echo -n "Enter your password: "
	read -s password

	stored_password=$(awk -F ',' -v email="$email" '$1 == email {print $5}' users/users.txt | base64 -d)
	if [[ -n "$stored_password" && "$stored_password" == "$password" ]]; then
		echo "Login successful!"
		echo "$(date +"%Y/%m/%d %H:%M:%S") LOGIN SUCCESS user with email $email logged in successfully" >> users/auth.log
		if [[ "$email" == *"admin"* ]]; then
			echo "Admin Menu"
			echo "1. Add User"
			echo "2. Edit User"
			echo "3. Delete User"
			echo "4. Logout"

			read pil_adm
			if [ "$pil_adm" -eq 4 ]; then
				echo "Logout successful!"
			elif [ "$pil_adm" -eq 3 ]; then
				delete_user
			elif [ "$pil_adm" -eq 1 ]; then
				add_user
			elif [ "$pil_adm" -eq 2 ]; then
				edit_user
			else
				echo "Please input valid number (1-4)"
			fi
		else
			echo "You don't have admin privileges. Welcome!"
		fi
	else
		echo "Invalid password or email not found!"
		echo "$(date +"%Y/%m/%d %H:%M:%S") LOGIN FAILED ERROR Failed loggin attempt on user with email $email" >> users/auth.log
	fi
}

if [ "$pil" -eq 2 ]; then
	forgot_pw
elif [ "$pil" -eq 1 ]; then
	login
fi