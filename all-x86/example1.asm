;tuto https://esauvage.developpez.com/tutoriels/asm/assembleur-intel-avec-nasm/?page=page_2

    mov ah, 0x0A ;le registre AH porte le numéro de la fonction, 0x0A
    mov al, 'B' ;le registre AL contient le numéro du caractère à afficher
    xor bx, bx ;le registre BH contient la page d'affichage, mettons 0 pour l'instant
    mov cx, 1 ;le registre CX contient le nombre de fois que l'on va afficher le caractère
    int 0x10
    ret