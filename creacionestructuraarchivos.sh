useradd -m prueba
useradd -m usuario1
useradd -m usuario2
useradd -m usuario3
useradd -m usuario4
useradd -m usuario5
useradd -m usuario6
useradd -m usuario7

groupadd grupo1
groupadd grupo2
groupadd grupo3

usermod -G root usuario1
usermod -G grupo2 usuario2
usermod -G grupo3 usuario3
usermod -G grupo3 usuario4
usermod -G grupo2 usuario5
usermod -G grupo3 usuario6
usermod -G grupo1 usuario7