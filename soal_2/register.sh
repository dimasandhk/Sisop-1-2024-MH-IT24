#!/bin/bash

echo "Welcome to Registration System"
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

echo "Akhir program"
