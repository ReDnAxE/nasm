;tuto https://esauvage.developpez.com/tutoriels/asm/assembleur-intel-avec-nasm/?page=page_2
;programme qui affiche une chaîne de caractères à l'écran quel que soit le système d'exploitation.
; comment compiler selon les SE ??

org 0x0100 ; Adresse de début .COM
 
;Ecriture de la chaîne hello dans la console
mov si, hello; met l'adresse de la chaîne à afficher dans le registre SI
xor bh, bh; RAZ de bh, qui stocke la page d'affichage
mov ah, 0x03;(fonction de int 0x10)
int 0x10; appel de l'interruption BIOS qui donne la position du curseur, stockée dans dx
mov cx, 1; nombre de fois où l'on va afficher un caractère
affiche_suivant:
mov al, [si];on met le caractère à afficher dans al
or al, al;on compare al à zéro pour s'arrêter
jz fin_affiche_suivant
cmp al, 13
je nouvelle_ligne
positionne_curseur:
mov ah, 0x02;on positionne le curseur (fonction de int 0x10)
int 0x10
mov ah, 0x0A;on affiche le caractère courant cx fois (fonction de int 0x10)
int 0x10
inc si; on passe au caractère suivant
inc dl; on passe à la colonne suivante pour la position du curseur
jmp affiche_suivant
fin_affiche_suivant:
ret
nouvelle_ligne:
inc dh; on passe à la ligne suivante
xor dl, dl; colonne 0
jmp positionne_curseur
hello: db 'Bonjour papi.', 13, 0