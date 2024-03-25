# Sisop Praktikum Modul 1-2024-MH-IT 24
Anggota Kelompok:
- Dimas Andhika Diputra 5027231074
- Mochamad Fadhil Saifullah 5027231068
- Thio Billy Amansyah 5027231007

## Soal 1
1.	`wget -O Sandbox.csv 'https://drive.google.com/uc?export=download&id=1cC6MYBI3wRwDgqlFQE1OQUN83JAreId0'`: Perintah ini menggunakan wget untuk mengunduh file CSV dari Google Drive. Opsi -O digunakan untuk menentukan nama file yang akan disimpan sebagai "Sandbox.csv".
2.	`echo "Pelanggan dengan sales tertinggi: "`: Ini hanya mencetak pesan ke layar untuk memberi tahu pengguna bahwa output selanjutnya akan menampilkan pelanggan dengan penjualan tertinggi.
3.	`echo "$(cat Sandbox.csv)" | awk -F ',' '{print $6",",$17}' | sort -t ',' -k2,2nr | head -n 1`: Bagian ini mengambil data dari file CSV, memprosesnya menggunakan awk untuk memilih kolom ke-6 (nama pelanggan) dan kolom ke-17 (nilai penjualan), kemudian mengurutkannya berdasarkan nilai penjualan (dari besar ke kecil) menggunakan sort, dan akhirnya mengambil baris pertama menggunakan `head -n 1`.
4.	`echo "Segment pelanggan dengan profit paling kecil: "`: Ini adalah pesan yang akan dicetak ke layar sebelum menampilkan segment pelanggan dengan profit terendah.
5.	`echo "$(cat Sandbox.csv)" | awk -F ',' '{print $7",",$20}' | sort -t ',' -k2,2n | head -n 2 | tail -n 1`: Ini mirip dengan langkah sebelumnya, hanya kali ini kita memilih kolom ke-7 (segment pelanggan) dan kolom ke-20 (profit), kemudian mengurutkannya berdasarkan profit (dari kecil ke besar), mengambil dua baris teratas, dan kemudian mengambil baris terakhir dari dua baris tersebut menggunakan `tail -n 1`.
6.	`echo "3 kategori dengan total profit tertinggi: "`: Ini hanya mencetak pesan ke layar untuk memberi tahu pengguna bahwa output selanjutnya akan menampilkan 3 kategori dengan total profit tertinggi.
7.	`echo "$(cat Sandbox.csv)" | awk -F ',' '{ categories[$14] += $20 } END { for (cat in categories) print cat",", categories[cat] }' | sort -t ',' -k2,2nr | head -n 3`: Bagian ini menggunakan awk untuk menghitung total profit untuk setiap kategori (kolom ke-14), kemudian mengurutkannya berdasarkan total profit (dari besar ke kecil), dan mengambil tiga baris teratas.
8.	`echo "Tanggal pembelian dan jumlah/kuantitas dari pelanggan Adriaens: "`: Ini adalah pesan yang akan dicetak ke layar sebelum menampilkan tanggal pembelian dan jumlah pesanan dari pelanggan dengan nama "Adriaens".
9.	`echo "$(cat Sandbox.csv)" | awk -F ',' '/Adriaens/ {print "Nama Pelanggan: "$6,"\nTanggal Pembelian: "$2,"\nJumlah Pesanan: "$18}'`: Ini menggunakan awk untuk mencari baris yang mengandung "Adriaens" dalam kolom ke-6 (nama pelanggan), kemudian mencetak nama pelanggan, tanggal pembelian (kolom ke-2), dan jumlah pesanan (kolom ke-18) dari baris tersebut

## Soal 2
### register.sh
Pertama2 saya buat sistem registrasinya yang menerima 5 input (email, username, security question, security question's answer, password)

```bash
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
```
untuk menerima input password di situ saya pakai `-s` agar apa yang diketikkan di terminal tidak terlihat.\
dan untuk selanjutnya saya cek beberapa syarat dari data yang diinputkan, jika sesuai baru saya masukkan ke `users/users.txt`.

```bash
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
```
syaratnya termasuk pastikan email tidak dipakai, dan syarat password seperti (Must be containing >= 8 char, at least 1 lowercase & uppercase letter, and at least 1 number)

### login.sh
Untuk sistem login ini, saya buat banyak function karena kompleksitas programnya
pertama saya dapatkan input user, apakah mau login atau forgot password

```bash
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
```
di situ saya buat 2 function jadi jika pilihannya 2 saya langsung jalankan function forgot_pw, jika 1 saya jalankan function login. di dalam function login ada program untuk function2 berikutnya (jika user seorang admin). Jadi di dalam program jika user seorang admin saya langsung dapatkan input lagi\
function delete user:
```bash
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
```
function add_user:
```bash
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
```
function edit_user:
```bash
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
```
pilihan admin:
```bash
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
```
di kode tersebut terlihat sama seperti sebelumnya function2 langsung dijalankan berdasarkan input dari admin. Untuk pembuatan function edit_user saya hanya menggabungkan dari function delete_user dan add_user

## Soal 3
### poin a (awal.sh)
Untuk poin a program dimulai dari download zip dan unzip semua file zip yang ada, kemudian di `awal.sh` saya gunakan `for in loop` untuk mengubah nama file yang kemudian di dekode dari hex ke ascii dari setiap file jpg yang didownload. Nama file jpg diubah ke `region - nama - element - senjata.jpg`. Kemudian setiap file jpg dimasukkan ke folder yang sesuai dengan nama regionnya.
```bash
wget -O genshin.zip "https://drive.google.com/uc?export=download&id=1oGHdTf4_76_RacfmQIV4i7os4sGwa9vN"
unzip genshin.zip

unzip genshin_character.zip

for encoded_file in genshin_character/*; do
    encoded_base=$(basename "$encoded_file")
    decoded_name=$(echo -n "$encoded_base" | xxd -r -p)
    mv "$encoded_file" "genshin_character/${decoded_name}.jpg"

    decoded_base=$(basename "$decoded_name")
    info=$(grep "$decoded_base" list_character.csv)

    name=$(echo "$info" | awk -F ',' '{print $1}')
    region=$(echo "$info" | awk -F ',' '{print $2}')
    element=$(echo "$info" | awk -F ',' '{print $3}')
    weapon=$(echo "$info" | awk -F ',' '{print $4}')

    mkdir -p "genshin_character/${region}"

    new_name="${region} - ${name} - ${element} - ${weapon}"
    clean_name=$(echo "$new_name" | tr -d '\015')
    mv "genshin_character/${decoded_name}.jpg" "genshin_character/${region}/${clean_name}.jpg"
done
```
### poin b (awal.sh)
untuk poin b saya juga menggunakan `for in loop` untuk menghitung jumlah masing2 senjata, dan terakhir untuk file `awal.sh` saya remove semua file2 yang tidak diperlukan seperti `genshin.zip`, `genshin_character.zip`, dan `list_character.csv`
```bash
for weapon in Catalyst Sword Claymore Bow Polearm; do
    count=$(find genshin_character/ -name "*$weapon.jpg" | wc -l)
    echo "$weapon: $count"
done

rm genshin.zip
rm genshin_character.zip
rm list_character.csv
```
### poin c, d, e (search.sh)
untuk poin c saya sedikit bingung karena apa yang saya dapatkan dari ekstrak steghide terformat dalam enkripsi base64 bukan hex, jadi di kode saya lakukan dekrip dengan base64, di situ saya juga lakukan `for in loop` lagi untuk folder genshin_character dan juga untuk folder region di dalamnya
```bash
for region in genshin_character/*; do
    for img in "$region"/*; do
        fname=$(echo "$img" | awk -F '/' '{print $3}')
        char=$(echo "$fname" | awk -F ' -' '{print $2}')
        steghide extract -sf "$img" -p "" -xf "${char}.txt"

        decoded=$(cat "${char}.txt" | base64 -d)

        echo "$fname -> $(cat "${char}.txt")"
        if [[ "$decoded" == *http* ]]; then
            wget "$decoded"
            echo "$(date +"%Y/%m/%d %H:%M:%S") FOUND $img" >> image.log
            echo "$decoded" > "${char}.txt"
            exit 0
        else
            echo "$(date +"%Y/%m/%d %H:%M:%S") NOT FOUND $img" >> image.log
            rm "${char}.txt"
        fi
        sleep 1
    done
done
```

## Soal 4