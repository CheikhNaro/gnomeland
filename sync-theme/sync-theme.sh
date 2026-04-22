#!/bin/bash

# Configuration
CONFIG_DIR="$HOME/.config/sync-theme"
ARC_MENU_JSON="$CONFIG_DIR/arcmenu-theme.json"
LAST_VAL=""

# Vérification de jq
command -v jq >/dev/null || { echo "Erreur: 'jq' est requis pour parser le JSON. Installez-le avec: sudo dnf install jq"; exit 1; }

# Fonction pour écrire dans dconf avec gestion intelligente des types
# ArcMenu attend souvent des chaînes pour les couleurs et des entiers pour les tailles
dconf_write() {
    local path="$1"
    local value="$2"
    
    # Si la valeur est vide, on ne fait rien
    [ -z "$value" ] && return

    # Détection du type : si c'est un nombre pur, on l'écrit tel quel, sinon on ajoute des guillemets
    if [[ "$value" =~ ^[0-9]+$ ]]; then
        dconf write "$path" "$value"
    else
        # Pour les chaînes dans dconf, il faut des doubles guillemets encapsulés dans des simples
        dconf write "$path" "'$value'"
    fi
}

apply_theme() {
    # Récupération de l'accent-color actuel
    VAL=$(gsettings get org.gnome.desktop.interface accent-color | tr -d "'")
    
    # Anti-boucle : ne rien faire si la couleur n'a pas changé
    if [ "$VAL" = "$LAST_VAL" ]; then
        return
    fi
    LAST_VAL="$VAL"

    echo " Changement détecté : $VAL"

    # Mapping des thèmes Marble et Yaru
    case "$VAL" in
        "blue")   THEME="Marble-blue-dark";   GTK_THEME="Yaru-Blue-dark" ;;
        "teal")   THEME="Marble-teal-dark";   GTK_THEME="Yaru-Teal-dark" ;;
        "green")  THEME="Marble-green-dark";  GTK_THEME="Yaru-Green-dark" ;;
        "yellow") THEME="Marble-yellow-dark"; GTK_THEME="Yaru-Yellow-dark" ;;
        "orange") THEME="Marble-orange-dark"; GTK_THEME="Yaru-Orange-dark" ;;
        "red")    THEME="Marble-red-dark";    GTK_THEME="Yaru-Red-dark" ;;
        "pink")   THEME="Marble-pink-dark";   GTK_THEME="Yaru-Pink-dark" ;;
        "purple") THEME="Marble-purple-dark"; GTK_THEME="Yaru-Purple-dark" ;;
        "slate")  THEME="Marble-slate-dark";  GTK_THEME="Yaru-Grey-dark" ;;
        *)        THEME="Marble-blue-dark";   GTK_THEME="Yaru-Blue-dark"; VAL="blue" ;;
    esac

    # 1. Application du thème Shell (User Themes extension)
    # Note: Le chemin dconf est le plus fiable pour cette extension
    dconf write /org/gnome/shell/extensions/user-theme/name "'$THEME'"
    
    # 2. Application du thème GTK
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"

    # 3. Application des couleurs ArcMenu
    if [ -f "$ARC_MENU_JSON" ]; then
        # On cherche la palette (ex: "blue-dark")
        TARGET_NAME="${VAL}-dark"
        
        # Extraction de la palette via jq (insensible à la casse pour le nom)
        PALETTE=$(jq -r --arg name "$TARGET_NAME" '.[] | select(.Name | ascii_downcase == ($name | ascii_downcase))' "$ARC_MENU_JSON")

        if [ -n "$PALETTE" ] && [ "$PALETTE" != "null" ]; then
            echo " Application de la palette ArcMenu : $TARGET_NAME"
            
            # Activation de l'override de thème ArcMenu (nécessaire pour que les couleurs s'appliquent)
            dconf write /org/gnome/shell/extensions/arcmenu/override-menu-theme "true"

            # Application de chaque clé
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-background-color "$(echo "$PALETTE" | jq -r '.Menu_Background_Color')"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-foreground-color "$(echo "$PALETTE" | jq -r '.Menu_Foreground_Color')"
            # Correction de la clé pour la bordure (certaines versions utilisent menu-border-color)
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-border-color "$(echo "$PALETTE" | jq -r '.Menu_Border_Color')"
            dconf_write /org/gnome/shell/extensions/arcmenu/border-color "$(echo "$PALETTE" | jq -r '.Menu_Border_Color')"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-border-size "$(echo "$PALETTE" | jq -r '.Menu_Border_Width')"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-border-radius "$(echo "$PALETTE" | jq -r '.Menu_Border_Radius')"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-font-size "$(echo "$PALETTE" | jq -r '.Menu_Font_Size')"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-separator-color "$(echo "$PALETTE" | jq -r '.Menu_Separator_Color')"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-item-hover-bg-color "$(echo "$PALETTE" | jq -r '.Item_Hover_Background_Color')"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-item-hover-fg-color "$(echo "$PALETTE" | jq -r '.Item_Hover_Foreground_Color')"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-item-active-bg-color "$(echo "$PALETTE" | jq -r '.Item_Active_Background_Color')"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-item-active-fg-color "$(echo "$PALETTE" | jq -r '.Item_Active_Foreground_Color')"
            
            echo " Thème ArcMenu mis à jour."
        else
            echo " Palette '$TARGET_NAME' non trouvée dans $ARC_MENU_JSON"
        fi
    else
        echo " Fichier JSON introuvable : $ARC_MENU_JSON"
    fi
}

# Exécution initiale
apply_theme

# Surveillance des changements via gsettings monitor (plus léger que dbus-monitor pour ce cas précis)
gsettings monitor org.gnome.desktop.interface accent-color | while read -r line; do
    # On attend un court instant pour laisser GNOME finir ses changements internes
    sleep 0.5
    apply_theme
done

