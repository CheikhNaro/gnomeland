#!/bin/bash

# Configuration
CONFIG_DIR="$HOME/.config/sync-theme"
ARC_MENU_JSON="$CONFIG_DIR/arcmenu-theme.json"
LAST_VAL=""

# JQ verification
command -v jq >/dev/null || { echo "Erreur: 'jq' est requis pour parser le JSON. Installez-le avec: sudo dnf install jq"; exit 1; }


dconf_write() {
    local path="$1"
    local value="$2"
    
    [ -z "$value" ] && return

    if [[ "$value" =~ ^[0-9]+$ ]]; then
        dconf write "$path" "$value"
    else

        dconf write "$path" "'$value'"
    fi
}

apply_theme() {
    # Fetch current accent-color
    VAL=$(gsettings get org.gnome.desktop.interface accent-color | tr -d "'")
    
    # Anti-loop
    if [ "$VAL" = "$LAST_VAL" ]; then
        return
    fi
    LAST_VAL="$VAL"

    echo " Change detected : $VAL"

    # Mapping Marble & Yaru themes
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

    # 1. Apply Shell theme (User Themes extension)
    dconf write /org/gnome/shell/extensions/user-theme/name "'$THEME'"
    
    # 2. Apply GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"

    # 3. Apply ArcMenu colours
    if [ -f "$ARC_MENU_JSON" ]; then
        
        TARGET_NAME="${VAL}-dark"
        
        PALETTE=$(jq -r --arg name "$TARGET_NAME" '.[] | select(.Name | ascii_downcase == ($name | ascii_downcase))' "$ARC_MENU_JSON")

        if [ -n "$PALETTE" ] && [ "$PALETTE" != "null" ]; then
            echo " Application de la palette ArcMenu : $TARGET_NAME"
            
            # Override ArcMenu Theme
            dconf write /org/gnome/shell/extensions/arcmenu/override-menu-theme "true"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-background-color "$(echo "$PALETTE" | jq -r '.Menu_Background_Color')"
            dconf_write /org/gnome/shell/extensions/arcmenu/menu-foreground-color "$(echo "$PALETTE" | jq -r '.Menu_Foreground_Color')"
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
            
            echo " ArcMenu theme updated !"
        else
            echo " '$TARGET_NAME' theme not found in $ARC_MENU_JSON"
        fi
    else
        echo " JSON file not found : $ARC_MENU_JSON"
    fi
}

apply_theme

# Monitoring changes
gsettings monitor org.gnome.desktop.interface accent-color | while read -r line; do

    sleep 0.5
    apply_theme
done

