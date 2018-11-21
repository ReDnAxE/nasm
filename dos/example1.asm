org 0x0100 ; Adresse de début .COM
    ;Ecriture de la chaîne hello dans la console
    mov dx, hello
    mov ah, 0x9; (fonction spécifique à l'interruption 0x21)
    int 0x21; (interruption spécifique à DOS)
    ret
    hello: db 'Bonjour papi.', 10, 13, '$'