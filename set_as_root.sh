#!/bin/bash

#On vérifie que le script est bien lancé en root EID -> 0
if [ "$EUID" -ne 0 ]; then
	echo "Pas root, merci de lancé le script en root !"
	exit 1
fi

#Vérification si un nom d'utilisateur à bien été renseigné comme 1er argument, $0 nous permet de récupéré le nom du fichier.
if [ -z "$1" ]; then
	echo "Merci d'utiliser : $0 username"
	exit 1
fi

#Vérification si l'utilisateur existe sur le systéme.
if ! id "$1" &>/dev/null; then
	echo "Utilisateur introuvable"
	exit 1
fi

#On modifie l'UID et GID pour le faire passé comme root grâce a usermod
usermod -u 0 -o "$1"

echo "Votre utilisateur à maintenant les même droit que Root."
echo "Vous pouvez maintenant vous connecter a cette utilisateur et tester !"