;tuto https://esauvage.developpez.com/tutoriels/asm/assembleur-intel-avec-nasm/?page=page_3
org 0x0100 ; Adresse de début .COM

;Ecriture de la chaîne hello dans la console
mov si, hello; met l'adresse de la chaîne à afficher dans le registre SI
call affiche_chaine
mov si, hello; met l'adresse de la chaîne à lire dans le registre SI
mov ah, 0x03
int 0x10; appel de l'interruption BIOS qui donne la position du curseur, stockée dans dx
mov cx, 1
attend_clavier:
mov ah, 0x01;on teste le buffer clavier
int 0x16
jz attend_clavier
;al contient le code ASCII du caractère
mov ah, 0x00;on lit le buffer clavier
int 0x16
mov [si], al;on met le caractère lu dans si
inc si
cmp al, 13
je fin_attend_clavier
;al contient le code ASCII du caractère
mov ah, 0x0A;on affiche le caractère courant cx fois
int 0x10
inc dl; on passe à la colonne suivante pour la position du curseur
mov ah, 0x02;on positionne le curseur
int 0x10
jmp attend_clavier
fin_attend_clavier:
inc dh; on passe à la ligne suivante pour la position du curseur
xor dl, dl
mov ah, 0x02;on positionne le curseur
int 0x10
mov byte [si], 0;on met le caractère terminal dans si
mov si, hello; met l'adresse de la chaîne à afficher dans le registre SI
call affiche_chaine

int 0x11
test ax, 0b0001
jnz lecteurs_disquette
mov si, pas_disquette
call affiche_chaine
test_coprocesseur:
test ax, 0b0010
jnz coprocesseur_present
mov si, pas_coprocesseur
call affiche_chaine
test_memoire:
and ax, 0b1100
shr ax, 2
inc ax; une zone mémoire est donnée gratis.
shl ax, 4; les zones mémoires sont comptées par paquets de 16 ko
mov si, hello
call nombre_vers_chaine
mov si, hello
call affiche_chaine
mov si, memoire_dispo
call affiche_chaine
ret

lecteurs_disquette:
mov si, disquettes
call affiche_chaine
jmp test_coprocesseur

coprocesseur_present:
mov si, coprocesseur
call affiche_chaine
jmp test_memoire

nombre_vers_chaine:
push bx
push cx
push dx
mov bl, 10
mov cx, 1
xor dh, dh
stocke_digit:
div bl;divise ax par bl (10)
mov dl, ah;récupère le reste dans dl (avec ça, on ne pourra pas traiter de nombre plus grand que 2550)
push dx ;sauve le reste dans la pile
inc cx
xor ah, ah ;RAZ le reste du div plus haut
or al, al;si al est autre que 0
jne stocke_digit

;Affichage du chiffre
boucle_digit:
loop affiche_digit;question: Ca s'arrête quand ?? quand al est à 0 ?
mov byte [si], 0
pop dx
pop cx
pop bx
ret

affiche_digit:
pop ax
add ax, '0';chiffres ASCII: il suffit d'ajouter "0" à un chiffre pour avoir son caractère.
mov [si], al
inc si
jmp boucle_digit
;fin nombre_vers_chaine

affiche_chaine:
push ax
push bx
push cx
push dx
xor bh, bh; RAZ de bh, qui stocke la page d'affichage
mov ah, 0x03
int 0x10; appel de l'interruption BIOS qui donne la position du curseur, stockée dans dx
mov cx, 1; nombre de fois où l'on va afficher un caractère
affiche_suivant:
mov al, [si];on met le caractère à afficher dans al
or al, al;on compare al à zéro pour s'arrêter
jz fin_affiche_suivant
cmp al, 13
je nouvelle_ligne
mov ah, 0x0A;on affiche le caractère courant cx fois
int 0x10
inc dl; on passe à la colonne suivante pour la position du curseur
positionne_curseur:
inc si; on passe au caractère suivant
mov ah, 0x02;on positionne le curseur
int 0x10
jmp affiche_suivant
fin_affiche_suivant:
pop dx
pop cx
pop bx
pop ax
ret
nouvelle_ligne:
inc dh; on passe à la ligne suivante
xor dl, dl; colonne 0
jmp positionne_curseur
;fin de affiche_chaine

disquettes: db 'Lecteur(s) de disquette', 13, 0
pas_disquette: db 'Pas de lecteur de disquette', 13, 0
coprocesseur: db 'Coprocesseur arithmétique', 13, 0
pas_coprocesseur: db 'Pas de coprocesseur', 13, 0
memoire_dispo: db ' ko.', 13, 0
hello: db 'Bonjour papi.', 13, 0