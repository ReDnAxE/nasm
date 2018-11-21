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
int 0x16; (gestionnaire de clavier BIOS)
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
ret

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

hello: db 'Bonjour papi.', 13, 0