#!/bin/sh

checkPkgPresence (){
    clear
    #vérification de la présence des packages vagrant et virtualbox
    dpkg -s vagrant 1> /dev/null && echo "Le package vagrant est bien installé" || sudo apt install vagrant
    dpkg -s virtualbox-6.0 1> /dev/null && echo "Le package virtualbox est bien installé" || sudo apt install virtualbox-6.0
    read -p "Tapez Entrée pour continuer "
}

menu (){
    clear
    echo "Que voulez-vous faire ?"
    echo " 1- Créer une machine virtuelle"
    echo " 2- Lister les machines virtuelles"
    echo " 3- Quitter le script"
    echo "---------------------"
}
editor (){
    clear
    echo "Que voulez vous faire sur la machine :"
    pwd
    echo " 1- Modifier le dossier synchronisé"
    echo " 2- Modifier l'adresse IP du serveur"
    echo " 3- Modifier la box de la machine"
    echo " 4- Démarrer la machine"
    echo " 5- Modifier LAMP"
}
createVM (){
    read -p "Quel est le nom de dossier local que vous voulez utiliser ? " localFileName
    read -p "Quel est le nom de dossier distant que vous voulez utiliser (basé sur /var/www/...) ? " distantFileName
    sed -i 's/config.vm.synced_folder ".\/data", "\/var\/www\/html"/config.vm.synced_folder ".\/'$localFileName'", "\/var\/www\/'$distantFileName'"/g' Vagrantfile
    mkdir $localFileName
    rm -rf data

    read -p "Quel est l'adresse IP que vous voulez utiliser ? " address
    sed -i 's/# config.vm.network "private_network", ip: "192.168.33.10"/config.vm.network "private_network", ip: "'$address'"/g' Vagrantfile

    echo "Quelle box voulez-vous utiliser ?"
    echo "1- ubuntu/xenial64"
    echo "2- ubuntu/trusty64"
    echo "3- ubuntu/precise64"
    read -p "Alors ? " box
    case $box in
    1)
        sed -i 's/config.vm.box = "base"/config.vm.box = "ubuntu\/xenial64"/g' Vagrantfile && echo "La box a été appliquée" || echo "La box n'a pas été appliquée"
    ;;
    2)
        sed -i 's/config.vm.box = "base"/config.vm.box = "ubuntu\/trusty64"/g' Vagrantfile && echo "La box a été appliquée" || echo "La box n'a pas été appliquée"
    ;;
    3)
        sed -i 's/config.vm.box = "base"/config.vm.box = "ubuntu\/precise64"/g' Vagrantfile && echo "La box a été appliquée" || echo "La box n'a pas été appliquée"
    ;;
    *)
        echo "Erreur lors de la saisie" && sleep 2
    ;;
    esac

    read -p "Voulez-vous démarrer la machine ? (oui/non) " turnOn
    case $turnOn in
    oui)
        vagrant up && echo "La machine est démarrée" || echo "La machine ne peut pas démarrer"

        echo "Quel(s) packets voulez-vous installer ?"
        echo "a- apache"
        echo "m- mysql"
        echo "p- php"
        echo "amp- apache mysql php"
        echo "aucun- ne rien installer"
        read -p "Alors ? " packets

        case $packets in
        a)
            command="sudo apt install apache2"
            vagrant ssh -c "$command -y" && read -p "Le package a bien été installé " || read -p "Le package n'a pas pu être installé "
        ;;
        m)
            command="sudo apt install mysql-server"
            vagrant ssh -c "$command -y" && read -p "Le package a bien été installé " || read -p "Le package n'a pas pu être installé "
        ;;
        p)
            command="sudo apt install php7.0"
            vagrant ssh -c "$command -y" && read -p "Le package a bien été installé " || read -p "Le package n'a pas pu être installé "
        ;;
        amp)
            command="sudo apt install php7.0 mysql-server apache2"
            vagrant ssh -c "$command -y" && read -p "Les packages ont bien été installés " || read -p "Les packages n'ont pas pu être installés"
        ;;
        aucun)
            read -p "Aucun package n'a été installé "
        ;;
        *)
            echo "Erreur lors de la saisie" && sleep 2
        ;;
        esac
    ;;
    non)
        echo "La machine n'a pas été démarrée"
        read -p "Retour au menu principal "
        menu
    ;;
    *)
        echo "Une erreur de saisie a été détectée, la machine ne sera par défaut pas démarrée"
        read -p "Retour au menu principal "
        menu
    ;;
    esac
}

checkPkgPresence
menu
while read -p "Votre choix : " choice; do
    #case permettant de diriger l'utilisateur sur la tache demandée
    case $choice in
        1)  
            clear
            echo " 1- Créer un dossier"
            echo " 2- Utiliser un dossier existant"
            echo " 3- Retour au menu"
            read -p "Votre choix : " createOrUseDir
            #case permettant de diriger l'utilisateur sur la création ou l'utilisation de dossier
            case $createOrUseDir in
                1)
                    read -p "Quel est le nom du dossier que vous voulez créer ? " makeDirName
                    mkdir $makeDirName && echo "Le dossier a été créé avec succès" || echo "Le dossier n'a pas pu être créé"
                    cd $makeDirName
                    echo "Vous êtes dans le dossier:"
                    pwd
                    echo "-----------------"
                    vagrant init 1> /dev/null && echo "Le fichier Vagrantfile a été généré" || echo "Le fichier Vagrantfile n'a pas pu être généré"
                    sed -i 's/# config.vm.synced_folder "..\/data", "\/vagrant_data"/config.vm.synced_folder ".\/data", "\/var\/www\/html"/g' Vagrantfile
                    mkdir data
                    createVM
                ;;
                2)
                    echo "Ci-dessous la liste des dossiers existants : "
                    ls -d */ --color
                    read -p "Quel est le nom du dossier que vous voulez utiliser ? " useDirName
                    cd $useDirName
                    echo "Vous êtes dans le dossier:"
                    pwd
                    echo "-----------------"
                    vagrant init 1> /dev/null && echo "Le fichier Vagrantfile a été généré" || echo "Le fichier Vagrantfile n'a pas pu être généré"
                    sed -i 's/# config.vm.synced_folder "..\/data", "\/vagrant_data"/config.vm.synced_folder ".\/data", "\/var\/www\/html"/g' Vagrantfile
                    mkdir data
                    createVM
                ;;
                3)
                    menu
                ;;
                *)
                    echo "Erreur lors de la saisie" && sleep 2
                ;;
            esac
        ;;
        2)
            clear
            vagrant global-status
            echo "Que voulez-vous faire ?"
            echo " 1- Démarrer une machine virtuelle"
            echo " 2- Eteindre une machine virtuelle"
            echo " 3- Supprimer une machine virtuelle"
            echo " 4- Retourner au menu"
            echo "---------------------"
            read -p "Alors ? " manageChoice
            case $manageChoice in
            1)
                read -p "Quel est l'ID de la machine que vous souhaitez démarrer ?" vmToTurnOn
                vagrant up $vmToTurnOn && read -p "La machine a été démarrée " || read -p "La machine n'a pas pu être démarrée "
            ;;
            2)
                read -p "Quel est l'ID de la machine que vous souhaitez éteindre ?" vmToTurnOff
                vagrant halt $vmToTurnOff && read -p "La machine a été éteinte " || read -p "La machine n'a pas pu être éteinte "
            ;;
            3)
                read -p "Quel est l'ID de la machine que vous souhaitez supprimer ? " vmToDelete
                read -p "Attention ! La machine avec l'ID $vmToDelete va être supprimée, êtes vous sûr ? (oui/non) " areUSure
                case $areUSure in
                oui)
                    vagrant destroy $vmToDelete && read -p "La machine a été supprimée " || read -p "La machine n'a pas pu être supprimée "
                ;;
                non)
                    read -p "Vous avez décidé de ne pas supprimer la machine, sage décision. "
                ;;
                *)
                    read -p "La réponse était incorrecte, par défaut la machine ne sera donc pas supprimée "
                ;;
                esac
            ;;
            4)
                menu
            ;;
            *)
                echo "Erreur lors de la saisie" && sleep 2
            ;;
            esac
            
        ;;
        3)
            break ;;
        *)
            echo "Erreur lors de la saisie" && sleep 2;;
    esac
    menu
done
echo "Vous avez décidé de quitter le script"