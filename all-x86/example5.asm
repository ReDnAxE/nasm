org 0x0100 ; Adresse de début .COM

;Ecriture de la chaîne hello dans la console
    mov si, hello; met l'adresse de la chaîne à afficher dans le registre SI
;    call affiche_chaine

    mov bx, 1; on va écrire les nombres avec un caractère terminal
    int 0x11
    test ax, 0b00000000000001
    jnz lecteurs_disquette
    mov si, pas
;    call affiche_chaine
fin_disquette:
    mov si, disquettes
;    call affiche_chaine
test_coprocesseur:
    test ax, 0b00000000000010
    jnz coprocesseur_present
    mov si, pas
;    call affiche_chaine
coprocesseur_present:
    mov si, coprocesseur
;    call affiche_chaine
test_memoire:
    push ax
    and ax, 0b00000000001100
    shr ax, 2
    inc ax; une zone mémoire est donnée gratis.
    shl ax, 4; les zones mémoires sont comptées par paquets de 16 ko
    mov di, hello
    call nombre_vers_chaine
    mov si, hello
;    call affiche_chaine
    mov si, memoire_dispo
;    call affiche_chaine

    pop ax
    push ax
    and ax, 0b00000000110000
    shr ax, 4
    cmp ax, 0b00
    je mode_graphique_actif
test_mode_texte_couleur40:
    cmp ax, 0b01
    je mode_texte_couleur40_actif
test_mode_texte_couleur80:
    cmp ax, 0b10
    je mode_texte_couleur80_actif
test_mode_texte_mono:
    cmp ax, 0b11
    je mode_texte_mono_actif
test_DMA:
    mov si, au_demarrage
;    call affiche_chaine
    pop ax
    test ax, 0b00000100000000
    jnz DMA_present
    mov si, pas
;    call affiche_chaine
DMA_present:
    mov si, DMA
;    call affiche_chaine
test_RS232:
    push ax
    and ax, 0b00111000000000
    shr ax, 9
    mov di, hello
    call nombre_vers_chaine
    mov si, hello
;    call affiche_chaine
    mov si, RS232
;    call affiche_chaine
    pop ax
    test ax, 0b01000000000000
    jnz manette_presente
    mov si, pas
;    call affiche_chaine
manette_presente:
    mov si, manette
;    call affiche_chaine
test_modem:
    test ax, 0b10000000000000
    jnz modem_present
    mov si, pas
;    call affiche_chaine
modem_present:
    mov si, modem_interne
;    call affiche_chaine
    shr ax, 14
    mov di, hello
    call nombre_vers_chaine
    mov si, hello
;    call affiche_chaine
    mov si, imprimantes
;    call affiche_chaine
;lecture mémoire disponible
    int 0x12
    mov di, hello
    call nombre_vers_chaine
    mov si, hello
;    call affiche_chaine
    mov si, memoire_dispo
;    call affiche_chaine

    mov ax, 0x4F00 ; demande infos sur le pilote VESA
    mov di, hello
    int 10h
    cmp al, 0x4F ; Si AL <> 0x4F, on n'a pas de VESA, donc fin.
    jne fin
    mov si, hello + 0x06 ; pointeur vers le nom de l'OEM stocké offset:segment
    lodsw; on charge l'adresse d'offset dans ax
    mov bx, ax ; BX contient l'adresse d'offset
    lodsw ; on charge l'adresse de segment dans ax
    mov si, bx ; SI pointe sur le nom de l'OEM
    push ds ; on sauvegarde DS
    mov ds, ax ; ds contient l'adresse de segment du nom de l'OEM
    call affiche_chaine
    pop ds ; on restaure DS
    mov si, retour_chariot
    call affiche_chaine

    mov si, hello + 0x0E ; pointeur vers la liste des modes supportés
    lodsw ; on charge l'adresse d'offset dans ax
    mov cx, ax ; cx contient l'adresse d'offset
    lodsw ; on charge l'adresse de segment dans ax
    mov si, cx ; si pointe sur le premier mode supporté
    mov dx, ax ; dx contient l'adresse de segment
lit_mode_suivant:
    push ds
    mov ds, dx ; ds contient l'adresse de segment de la liste des modes
    lodsw ;charge dans ax le mode
    pop ds
    cmp ax, 0xFFFF ; Fin de la liste
    je arret_modes
    xor ah, ah ; on enlève le haut du mode
    mov di, hello ; on écrit dans hello
    mov bx, 1
    call nombre_vers_chaine
    mov al, ' '
    mov ah, 0 ; on met 2 caractères d'un coup après la chaîne : un espace et le zéro terminal.
    stosw ; les caractères sont dépilés, c'est à dire qu'il faut placer le premier dans la zone basse
    push si ;sauve si sur la pile
    mov si, hello
    call affiche_chaine
    pop si ; on récupère si
    jmp lit_mode_suivant
arret_modes:
    mov si, retour_chariot ; Affichage d'un retour chariot
    call affiche_chaine
    mov cx, [mode_souhaite] ; On s'enquiert du mode souhaité
;suite_mode_VESA:
    mov ax, 0x4F01 ; demande infos sur le mode VESA
    mov di, hello
    int 0x10
    cmp al, 0x4F ; Si AL <> 0x4F, la fonction n'est pas supportée, on se contentera du VGA.
    jne adresse_mode_13h
    cmp ah, 0x01 ; idem en cas de AH à 1
    je adresse_mode_13h
    mov si, hello ; pointeur vers la zone de données remplie par l'interruption
    lodsw
    test ax, 0b1 ; mode supporté ?
    jz adresse_mode_13h ; On se contente du VGA
    mov si, hello + 0x06 ; pointeur vers la taille de la fenêtre graphique
    mov di, taille_fenetre ; pointeur vers notre structure à nous
    mov ax, ds ; DS = ES
    mov es, ax
    movsw ; SI pointe maintenant vers l'adresse du segment de la fenêtre A
    movsw ; taille_fenetre et adr_fen_A sont maintenant stockées
    mov ax, [adr_fen_A]
    or ax, ax ; on teste l'adresse du segment de la fenêtre. Si elle est nulle, on passe en mode 0x13
    jnz adresse_OK
adresse_mode_13h:
    mov word [mode_souhaite], 0x0013 ; infos du mode 0x13, le mode VGA
    mov word [adr_fen_A], 0xA000
adresse_OK:
    mov di, hello ; met l'adresse de la chaîne à lire dans le registre SI
    call lit_chaine ; On attend l'utilisateur pour nettoyer l'écran

    mov ax, 0x4F02
    mov bx, [mode_souhaite]
    int 0x10 ; Changement de mode vidéo
    mov si, adr_fen_A
    lodsw
    mov es, ax;
    xor di, di
    mov ax, [taille_fenetre]
    shr ax, 1 ; On va remplir 2 octets par 2 octets, on divise donc la taille par 2
    mov cx, 1000 ; Elle est donnée en 1000 octets
    mul cx ; Donc on multiplie par 1000
    mov cx, ax ; Et on met ça dans le compteur
    mov ax, 0x0101 ; Deux fois de suite la couleur à appliquer
    rep stosw ; et on boucle

    mov ax, 160 ; Coordonnée X
    mov bx, 100 ; Coordonnée Y
    mov dx, 0x03; Couleur
    call affiche_point
    push 100
    push 10
    push 100
    push 20
    mov dx, 0x04; Couleur
    call affiche_ligne
    pop ax
    pop ax
    pop ax
    pop ax
    push 102
    push 20
    push 102
    push 10
    mov dx, 0x05; Couleur
    call affiche_ligne
    pop ax
    pop ax
    pop ax
    pop ax
    push 114
    push 10
    push 104
    push 10
    mov dx, 0x06; Couleur
    call affiche_ligne
    pop ax
    pop ax
    pop ax
    pop ax
    push 104
    push 20
    push 114
    push 20
    mov dx, 0x07; Couleur
    call affiche_ligne
    pop ax
    pop ax
    pop ax
    pop ax
    push 126
    push 20
    push 124
    push 10
    mov dx, 0x08; Couleur
    call affiche_ligne
    pop ax
    pop ax
    push 116
    push 18
    mov dx, 0x09; Couleur
    call affiche_ligne
    pop ax
    pop ax
    push 124
    push 30
    mov dx, 0x0A; Couleur
    call affiche_ligne
    pop ax
    pop ax
    push 116
    push 22
    mov dx, 0x0B; Couleur
    call affiche_ligne
    pop ax
    pop ax
    push 132
    push 10
    mov dx, 0x0C; Couleur
    call affiche_ligne
    pop ax
    pop ax
    push 136
    push 16
    mov dx, 0x0D; Couleur
    call affiche_ligne
    pop ax
    pop ax
    push 136
    push 24
    mov dx, 0x0E; Couleur
    call affiche_ligne
    pop ax
    pop ax
    push 132
    push 30
    mov dx, 0x0F; Couleur
    call affiche_ligne
    pop ax
    pop ax
    pop ax
    pop ax
    mov di, hello; met l'adresse de la chaîne à lire dans le registre SI
    call lit_chaine ; On attend la volonté de l'utilisateur
    mov ax, 0x4F02 ; Retour au mode texte
    mov bx, 0x0003; 80 * 25, mode texte
    int 0x10
    mov di, hello; met l'adresse de la chaîne à lire dans le registre SI
    call lit_chaine ; On attend la volonté de l'utilisateur
fin:
    ret

lecteurs_disquette:
;On a un lecteur de disquette. Les bits 6 et 7 de AX en donnent le nombre
    push ax
    and ax, 0b0000000011000000
    shr ax, 6
    inc ax
    mov di, hello
    call nombre_vers_chaine
    mov si, hello
    call affiche_chaine
    pop ax
    jmp fin_disquette

mode_graphique_actif:
    mov si, mode_graphique
    call affiche_chaine
    jmp test_mode_texte_couleur40

mode_texte_couleur40_actif:
    mov si, mode_texte_couleur40
    call affiche_chaine
    jmp test_mode_texte_couleur80

mode_texte_couleur80_actif:
    mov si, mode_texte_couleur80
    call affiche_chaine
    jmp test_mode_texte_mono

mode_texte_mono_actif:
    mov si, mode_texte_mono
    call affiche_chaine
    jmp test_DMA

;écrit dans la chaîne pointée par DI le nombre contenu dans AX
;si BL est à un, on écrit un caractère terminal
;BH contient le nombre minimal de caractères à utiliser
nombre_vers_chaine:
    push cx
    push dx
    push bx
    mov bx, 10
    mov cx, 1
    xor dx, dx
stocke_digit:
    div bx
;    mov dl, ah
    push dx ;sauve le reste dans la pile
    inc cx
;    xor ah, ah
    xor dx, dx
    or ax, ax
    jne stocke_digit

    inc bh
ajout_zero:
    cmp bh, cl
    jbe boucle_digit
    push 0
    inc cx
    jmp ajout_zero
;Affichage du chiffre
boucle_digit:
    dec bh
    loop affiche_digit
    pop bx ; on récupère le paramètre bx
    test bl, 0b1 ; s'il est à 1, on écrit un caractère terminal
    jz depile
    mov byte [di], 0
depile:
    pop dx
    pop cx
ret

affiche_digit:
    pop ax
    add ax, '0'
    stosb ; met AL dans l'octet pointé par DI et incrémente DI
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
    lodsb
    or al, al;on compare al à zéro pour s'arrêter
    jz fin_affiche_suivant
    cmp al, 13
    je nouvelle_ligne
    mov ah, 0x0A;on affiche le caractère courant cx fois
    int 0x10
    inc dl; on passe à la colonne suivante pour la position du curseur
    cmp dl, 80
    je nouvelle_ligne
positionne_curseur:
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

lit_chaine:
    push ax
    push cx
    push dx
    mov ah, 0x03
    int 0x10; appel de l'interruption BIOS qui donne la position du curseur, stockée dans dx
    mov cx, 1
attend_clavier:
    mov ah, 0x01;on teste le buffer clavier
    int 0x16
    jz attend_clavier
    ;al contient le code ASCII du caractère
    xor ah, ah; on lit le buffer clavier
    int 0x16
    stosb
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
    mov byte [di], 0;on met le caractère terminal dans si
    pop dx
    pop cx
    pop ax
    ret
;fin de lit_chaine

;fonction affiche_point : on est déjà dans un mode graphique
;AX : Coordonnée X du point
;BX : Coordonnée Y du point
;dL : Couleur du point
affiche_point:
    push si ; On sauve les registres qu'on va manipuler
    push es
    push di
    push ax
    mov si, adr_fen_A ; On lit l'adresse de départ de la mémoire vidéo
    lodsw
    mov es, ax ; On va dans la mémoire vidéo
    mov di, bx ; BX contient la coordonnée Y, qu'on va traiter
    shl di, 6 ; = Y * 64
    push di ; Y2 = Y * 64
    shl di, 2 ; = Y2 * 4 = Y * 256
    pop ax ; on récupère Y2
    add di, ax ; IndexY = Y * 256 + Y2 = Y * 256 + Y * 64 = Y * 320
    pop ax ; On récupère la coordonnée X
    add di, ax ; index = IndexY + X
    push ax ; On remet X dans la pile
    mov al, dl ; On fixe la couleur du pixel
    stosb ; Et on l'écrit dans la mémoire vidéo
    pop ax ; On restaure les registres manipulés
    pop di
    pop es
    pop si
    ret
;fin de affiche_point

;fonction affiche_ligne : on est déjà dans un mode graphique
; DL contient la couleur
affiche_ligne:
    jmp depart_affiche_ligne
Y2: dw 0
X2: dw 0
Y1: dw 0
X1: dw 0
deltaX: dw 0
deltaY: dw 0
incX: dw 0
incY: dw 0
e: dw 0
couleur: db 0
depart_affiche_ligne:
    push si
    push ax
    mov ax, sp
    mov si, ax
    add si, 6 ; SI pointe sur Y2
    push bx
    push cx
    push dx
    push di
    mov di, Y2
    mov ax, ds
    mov es, ax
    mov cx, 4
    rep movsw
    mov [couleur], dl
    mov ax, [X2]
    mov bx, [X1]
    sub ax, bx
    mov [deltaX], ax
    mov cx, [Y2]
    mov bx, [Y1]
    sub cx, bx
    mov [deltaY], cx
    or ax, ax ; test deltaX
    jnz test_deltaX_positif
    or cx, cx ; test deltaY
    jnz test_deltaY_deltaX_nul
fin_affiche_ligne:
    mov dl, [couleur]
    mov ax, [X2]
    mov bx, [Y2]
    call affiche_point
    mov ax, [X1]
    mov bx, [Y1]
    call affiche_point
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    ret

deltaX_positif:
    or cx, cx
    jnz test_deltaY_deltaX_positif
    ;vecteur horizontal vers la droite
    mov cx, [deltaX]
    mov dx, 1
    mov word [incX], 1
    mov word [incY], 0
    jmp ligne_H_V

test_deltaY_deltaX_nul:
    mov word [incY], 1
    mov word [incX], 0
    cmp cx, 0
    jns ligne_H_V
    neg cx
    mov word [incY], -1
ligne_H_V:
    mov ax, [X1]
    mov bx, [Y1]
    mov dl, [couleur]
boucle_H_V:
    loop avance_H_V
    jmp fin_affiche_ligne

avance_H_V:
    add ax, [incX]
    add bx, [incY]
    call affiche_point
    jmp boucle_H_V

test_deltaX_positif:
    cmp ax, 0
    jns deltaX_positif
    or cx, cx
    jnz test_deltaY_deltaX_negatif
    ;vecteur horizontal vers la gauche
    mov cx, [deltaX]
    neg cx
    mov dx, -1
    mov word [incX], -1
    mov word [incY], 0
    jmp ligne_H_V

charge_registres:
    shl cx, 1
    shl ax, 1
    mov [deltaY], cx
    mov [deltaX], ax
    mov ax, [X1]
    mov bx, [Y1]
    ret

charge_e_deltaX_et_cmp_X2:
    mov [e], ax
    call charge_registres
    mov cx, [X2]
    ret

charge_e_deltaY_et_cmp_Y2:
    mov [e], cx
    call charge_registres
    mov cx, [Y2]
    ret

affiche_et_charge_eY:
    mov dl, [couleur]
    call affiche_point
    add bx, [incY]
    mov dx, [e]
    ret

affiche_et_charge_eX:
    mov dl, [couleur]
    call affiche_point
    add ax, [incX]
    mov dx, [e]
    ret

octants1_et_4:
    call charge_e_deltaX_et_cmp_X2
depart_boucle1:
    call affiche_et_charge_eX
    cmp ax, cx
    je fin_affiche_ligne
    sub dx, [deltaY]
    cmp dx, 0
    jns X_pret1
    add bx, [incY]
    add dx, [deltaX]
X_pret1:
    mov [e], dx
    jmp depart_boucle1

deltaY_positif_deltaX_negatif:
    neg ax
deltaY_positif_deltaX_positif:
    mov word [incY], 1
    ;deltaY > 0, deltaX > 0
    cmp ax, cx
    jae octants1_et_4
    neg ax
    call charge_e_deltaY_et_cmp_Y2
depart_boucle2_et_3:
    call affiche_et_charge_eY
    cmp bx, cx
    je fin_affiche_ligne
    add dx, [deltaX]
    cmp dx, 0
    jns X_pret2_et_3
    add ax, [incX]
    add dx, [deltaY]
X_pret2_et_3:
    mov [e], dx
    jmp depart_boucle2_et_3

octant5:
    call charge_e_deltaX_et_cmp_X2
depart_boucle5:
    call affiche_et_charge_eX
    cmp ax, cx
    je fin_affiche_ligne
    sub dx, [deltaY]
    cmp dx, 0
    js X_pret5
    add bx, [incY]
    add dx, [deltaX]
X_pret5:
    mov [e], dx
    jmp depart_boucle5

octant8:
    neg cx
    call charge_e_deltaX_et_cmp_X2
depart_boucle8:
    call affiche_et_charge_eX
    cmp ax, cx
    je fin_affiche_ligne
    add dx, [deltaY]
    cmp dx, 0
    jns X_pret8
    add bx, [incY]
    add dx, [deltaX]
X_pret8:
    mov [e], dx
    jmp depart_boucle8

test_deltaY_deltaX_positif:
    mov word [incX], 1
    cmp cx, 0
    jns deltaY_positif_deltaX_positif
    ;deltaY < 0, deltaX > 0
    mov word [incY], -1
    neg cx
    cmp ax, cx
    jae octant8
    neg cx
    jmp octants6_et_7

test_deltaY_deltaX_negatif:
    mov word [incX], -1
    cmp cx, 0
    jns deltaY_positif_deltaX_negatif
    ;deltaY < 0, deltaX < 0
    mov word [incY], -1
    cmp ax, cx
    jbe octant5
    neg ax
octants6_et_7:
    call charge_e_deltaY_et_cmp_Y2
depart_boucle6_et_7:
    call affiche_et_charge_eY
    cmp bx, cx
    je fin_affiche_ligne
    add dx, [deltaX]
    cmp dx, 0
    js X_pret6_et_7
    add ax, [incX]
    add dx, [deltaY]
X_pret6_et_7:
    mov [e], dx
    jmp depart_boucle6_et_7
;AFFICHE_LIGNE ENDP

mode_souhaite: dw 0x0013
taille_fenetre: dw 0
adr_fen_A: dw 0
disquettes: db ' lecteur(s) de disquette installé(s).', 13, 0
pas: db 'Pas de ', 0
coprocesseur: db 'Coprocesseur arithmétique.', 13, 0
memoire_dispo: db ' ko.', 13, 0
mode_graphique: db 'Mode graphique', 0
mode_texte_couleur40: db 'Mode texte couleur 40 * 25', 0
mode_texte_couleur80: db 'Mode texte couleur 80 * 25', 0
mode_texte_mono: db 'Mode texte monochrome 80 * 25', 0
au_demarrage: db ' au démarrage.', 13, 0
DMA: db 'DMA.', 13, 0
RS232: db ' port(s) RS232 disponible(s).', 13, 0
manette: db 'Manette de jeu.', 13, 0
modem_interne: db 'Modem interne.', 13, 0
imprimantes: db ' imprimante(s) connectée(s).', 13, 0
heure: db '00 h 00 min 00 s', 13, 0
retour_chariot: db 13, 0
hello: db 'Bonjour papi. Je cherche une ligne de plus de quatre vingts caractères. Ce doit être relativement facile à trouver, non ?', 13, 0