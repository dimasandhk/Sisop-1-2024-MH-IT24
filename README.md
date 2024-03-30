# Sisop Praktikum Modul 1-2024-MH-IT 24
Anggota Kelompok:
- Dimas Andhika Diputra 5027231074
- Mochamad Fadhil Saifullah 5027231068
- Thio Billy Amansyah 5027231007

## Soal 1 (tidak revisi)
1.	`wget -O Sandbox.csv 'https://drive.google.com/uc?export=download&id=1cC6MYBI3wRwDgqlFQE1OQUN83JAreId0'`: Perintah ini menggunakan wget untuk mengunduh file CSV dari Google Drive. Opsi -O digunakan untuk menentukan nama file yang akan disimpan sebagai "Sandbox.csv".
2.	`echo "Pelanggan dengan sales tertinggi: "`: Ini hanya mencetak pesan ke layar untuk memberi tahu pengguna bahwa output selanjutnya akan menampilkan pelanggan dengan penjualan tertinggi.
3.	`echo "$(cat Sandbox.csv)" | awk -F ',' '{print $6",",$17}' | sort -t ',' -k2,2nr | head -n 1`: Bagian ini mengambil data dari file CSV, memprosesnya menggunakan awk untuk memilih kolom ke-6 (nama pelanggan) dan kolom ke-17 (nilai penjualan), kemudian mengurutkannya berdasarkan nilai penjualan (dari besar ke kecil) menggunakan sort, dan akhirnya mengambil baris pertama menggunakan `head -n 1`.
4.	`echo "Segment pelanggan dengan profit paling kecil: "`: Ini adalah pesan yang akan dicetak ke layar sebelum menampilkan segment pelanggan dengan profit terendah.
5.	`echo "$(cat Sandbox.csv)" | awk -F ',' '{print $7",",$20}' | sort -t ',' -k2,2n | head -n 2 | tail -n 1`: Ini mirip dengan langkah sebelumnya, hanya kali ini kita memilih kolom ke-7 (segment pelanggan) dan kolom ke-20 (profit), kemudian mengurutkannya berdasarkan profit (dari kecil ke besar), mengambil dua baris teratas, dan kemudian mengambil baris terakhir dari dua baris tersebut menggunakan `tail -n 1`.
6.	`echo "3 kategori dengan total profit tertinggi: "`: Ini hanya mencetak pesan ke layar untuk memberi tahu pengguna bahwa output selanjutnya akan menampilkan 3 kategori dengan total profit tertinggi.
7.	`echo "$(cat Sandbox.csv)" | awk -F ',' '{ categories[$14] += $20 } END { for (cat in categories) print cat",", categories[cat] }' | sort -t ',' -k2,2nr | head -n 3`: Bagian ini menggunakan awk untuk menghitung total profit untuk setiap kategori (kolom ke-14), kemudian mengurutkannya berdasarkan total profit (dari besar ke kecil), dan mengambil tiga baris teratas.
8.	`echo "Tanggal pembelian dan jumlah/kuantitas dari pelanggan Adriaens: "`: Ini adalah pesan yang akan dicetak ke layar sebelum menampilkan tanggal pembelian dan jumlah pesanan dari pelanggan dengan nama "Adriaens".
9.	`echo "$(cat Sandbox.csv)" | awk -F ',' '/Adriaens/ {print "Nama Pelanggan: "$6,"\nTanggal Pembelian: "$2,"\nJumlah Pesanan: "$18}'`: Ini menggunakan awk untuk mencari baris yang mengandung "Adriaens" dalam kolom ke-6 (nama pelanggan), kemudian mencetak nama pelanggan, tanggal pembelian (kolom ke-2), dan jumlah pesanan (kolom ke-18) dari baris tersebut

screenshot:\
![image](https://github.com/dimasandhk/Sisop-1-2024-MH-IT24/assets/70847887/43a13e0b-c148-4f3c-b5e2-a8b8ee925072)


## Soal 2 (tidak revisi)
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

screenshot (register):\
![image](https://github.com/dimasandhk/Sisop-1-2024-MH-IT24/assets/70847887/7acc1506-71af-4cc2-860d-51955d7c3857)\

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

screenshot (login non admin):\
![image](https://github.com/dimasandhk/Sisop-1-2024-MH-IT24/assets/70847887/3021af6a-582c-4846-a880-991d23fcd6a3)\
screenshot (login admin):\
![image](https://github.com/dimasandhk/Sisop-1-2024-MH-IT24/assets/70847887/4469fdb3-44cc-4573-a8e0-e93cdbbacdec)\
screenshot (forgot pw):\
![image](https://github.com/dimasandhk/Sisop-1-2024-MH-IT24/assets/70847887/8c2493c4-f757-4d37-a3bd-cf38726298b1)

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
tree setelah run `awal.sh`:\
![image](https://github.com/dimasandhk/Sisop-1-2024-MH-IT24/assets/70847887/c3b0a644-ab2f-4318-ad08-32b20047726e)\
hasil perhitungan wep:\
![image](https://github.com/dimasandhk/Sisop-1-2024-MH-IT24/assets/70847887/96c20f57-7962-4d58-9b3d-a4f7f7f1ef35)


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

isi log:\
![image](https://github.com/dimasandhk/Sisop-1-2024-MH-IT24/assets/70847887/6c86daf6-19d4-47b8-81a8-e1c7e34d12af)\
isi txt (hasil decrypt ekstrak steghide dari gambar):\
![image](https://github.com/dimasandhk/Sisop-1-2024-MH-IT24/assets/70847887/9b98e4c2-d0ab-4478-a123-a614ce05cc39)

## Soal 4
### minute_log.sh
Mencatat penggunaan memory user setiap menit dengan command `free` dan `du`.

```
## Making the log file and dir required
cd ~; if [! -d log] ;then mkdir log ; fi; cd log
date=$(date "+%Y%m%d%k%M%S")
min="metrics_$date.log"
touch "$min"
chmod 700 "$min"
...
```
Bagian ini membuat direktori dan log file beserta user premission. Nama log file dimasukkan ke dalam variabel agar mempermudah dijadikan input dalam kode selanjutnya.

```
...
## Header of log file
echo "mem_total,mem_used,mem_free,mem_shared,mem_buff,mem_available,swap_total,swap_used,swap_free,path,path_size" >"$min"

## Runs on infinite loop
while true ; do
    ## Output log for every minute loop
    { free -m; du -sh ~;} | awk 'NR==2 {print $2","$3","$4","$5","$6","$7}
    NR==3 {print $2","$3","$4}
    NR==4 {print $2","$1}
    ' | paste -s -d ',' >> "$min" 
...
        
```
Barisan yang mengandung nama kolom dicetak terlebih dahulu di luar infinite loop agar tidak tercetak berulang-ulang ketika memory pengguna dicatat setiap menit.

Menyatukan output dari beberapa command dapat dicapai dengan menutupnya dalam kurung kurawal `{` sebelum dilakukan piping.

```
baboi@baboi:~/Downloads/test$ sh ss.sh
15552,3911,10305,552,2221,11640
976,0,976
/home/baboi,15G              
                                                                
baboi@baboi:~/Downloads/test$ sh ss.sh
15552,3943,10274,555,2224,11608,976,0,976,/home/baboi,15G    <-- setelah disatukan
```
Hasil dari command kemudian dipilih-pilih dengan `awk` lalu disatukan oleh `paste` sebelum dicetak ke dalam log file.

```
...
## Adding 'i' counter every minute
i=$(($i+1))
sleep 60

## Create aggregate log file every hour
if [ $(($i % 60)) -eq 0 ] ; then
    sh aggregate_minutes_to_hourly_log.sh "$min"
fi
```
Digunakan `i` sebagai counter waktu dimana bertambah setiap menit. Jika `i` mencapai nilai 60, maka `if` statement akan menjalankan script yang memberikan nilai max, min, dan rata-rata dari setiap segi memori yang dicatat sejak program dijalankan. 

### aggregate_minutes_to_hourly_log.sh
```
## Create the aggregate log file
datehr=$(date "+%Y%m%d%k")
hr="metrics_$datehr.log"
touch "$hr"
chmod 700 "$hr"
min=$1

echo "type,mem_total,mem_used,mem_free,mem_shared,mem_buff,mem_available,swap_total,swap_used,swap_free,path,path_size" >"$hr"
...
```
Menciptakan log file dan mencetak header untuk file aggregat dengan tambahan dimasukannya variabel yang berisi judul dari log file yang akan dipakai.

```
...
## Generate min, max, and avg
cat "$min" | awk 'BEGIN{FS=","; OFS=","} 
    NR>1{ min=$4;
        if ($4>=max) {smax=$0}    <-- Anomali if conditional
        max=($4>max)?$4:max    

        if ($4<=min){smin=$0} 
        min=($4<min)?$4:min 
    }
    END {print "minimum", smax; print "maximum", smax }
' >>"$hr"
...
```
Log file dibuka dan dicari *record*, konteks `awk`, dengan nilai maksimum dan minimumnya. Collumn 4 merepresentasikan shared memory. Hal itu menjadi patokan karena nilainya yang cenderung berubah-ubah dibanding dengan yang lain.
```
mem_total,mem_used,mem_free,mem_shared,mem_buff,mem_available,swap_total,swap_used,swap_free,path,path_size
15552,2912,11490,412,1892,12639,976,0,976,/home/baboi,15G
15552,2917,11486,425,1904,12634,976,0,976,/home/baboi,15G
15552,2911,11491,434,1914,12640,976,0,976,/home/baboi,15G
15552,2921,11481,443,1923,12630,976,0,976,/home/baboi,15G
15552,2887,11515,420,1900,12664,976,0,976,/home/baboi,15G
                  ^ Baris empat dan lima cukup sering berubah nilai
```
Masih menjadi pertanyaan namun `if(cond)` dengan `(cond)?s1:s2` nampaknya memiliki implementasi yang berbeda dalam `awk` karena ketika menggunakan salah satu jenis conditional pada bagian min/max, maka akan menghasilkan error atau tidak sesuai yang diinginkan.
```
...
smax=($4>=max)$0:"";    <-- anomali
max=($4>max)?$4:max 
...
```
Bagian nilai rata-rata dipisahkan karena pencetakkan array dalam awk menggunakan for loop tidak dapat dihasilkan dalam satu baris.
```
...
cat "$min" | awk -v usr="$USER" 'BEGIN{FS=","; OFS=","} 
    NR>1{ for(i = 1; i <= NF; i++) sum[i]+=$i } 
    END { print "average"; for(i = 1; i <= NF; i++) {
            if (i!=10)  {print sum[i]/(NR-1)} 
            else {print "/home/" usr}
        }
    }
' | paste -s -d "," >>"$hr"

---Terminal---
baboi@baboi:~/Downloads/test$ sh ss.sh
average
15552
2909.6
11492.6
426.8
1906.6
12641.4
976
0
976
/home/baboi
15

```
