package util;

import java.util.Arrays;
import java.util.List;

public class IconUtil {

    // Senarai lengkap 93 ikon dari import lucide-react anda (dalam format kebab-case)
    public static final List<String> ALL_ICONS = Arrays.asList(
        "activity", "alert-circle", "alert-triangle", "apple", "arrow-left",
        "arrow-right", "arrow-up-right", "award", "bar-chart-3", "bell",
        "book-open", "bookmark", "briefcase", "building", "calendar",
        "calendar-check", "camera", "check", "check-check", "check-circle",
        "check-circle-2", "check-square", "chevron-down", "chevron-left", "chevron-right",
        "chevron-up", "circle", "clipboard-list", "clock", "compass",
        "copy", "database", "dollar-sign", "download", "edit-2",
        "edit-3", "external-link", "eye", "file-badge", "file-edit",
        "file-spreadsheet", "file-text", "filter", "graduation-cap", "hash",
        "heart", "heart-handshake", "help-circle", "history", "hourglass",
        "image", "info", "key-round", "layers", "layout",
        "layout-grid", "lightbulb", "list", "lock", "log-out",
        "mail", "map-pin", "message-circle", "message-square", "message-square-plus",
        "more-vertical", "newspaper", "palmtree", "paperclip", "party-popper",
        "pen-tool", "percent", "phone", "pin", "plus",
        "printer", "refresh-cw", "rotate-ccw", "save", "search",
        "send", "settings", "share-2", "shield", "shield-check",
        "sliders-horizontal", "smile", "sparkles", "star", "target",
        "trash-2", "trending-up", "trophy", "user", "user-check",
        "user-plus", "users", "video", "volume-2", "volume-x",
        "x", "x-circle"
    );

    /**
     * Menukar nama komponen React (cth: "MessageSquarePlus" atau "ImageIcon")
     * kepada nama atribut data-lucide ("message-square-plus" atau "image").
     */
    public static String toKebabCase(String reactIconName) {
        if (reactIconName == null || reactIconName.isBlank()) return "circle";
        if ("ImageIcon".equals(reactIconName)) return "image";
        return reactIconName
                .replaceAll("([a-z])([A-Z0-9])", "$1-$2")
                .replaceAll("([A-Z])([A-Z][a-z])", "$1-$2")
                .toLowerCase();
    }

    /**
     * Menjana tag HTML <i> untuk digunakan terus di dalam JSP.
     * Contoh: <%= IconUtil.icon("Send", "icon-sm") %>
     */
    public static String icon(String name, String cssClass) {
        String kebab = toKebabCase(name);
        String cls = (cssClass != null && !cssClass.isBlank()) ? " class=\"" + cssClass + "\"" : "";
        return "<i data-lucide=\"" + kebab + "\"" + cls + "></i>";
    }

    /**
     * Menjana kotak ikon bertema Neobrutalism.
     * Contoh: <%= IconUtil.box("MessageCircle", "nb-bg-yellow", "icon-md") %>
     */
    public static String box(String name, String boxThemeClass, String iconSizeClass) {
        String theme = (boxThemeClass != null) ? boxThemeClass : "";
        return "<span class=\"nb-icon-box " + theme + "\">" + icon(name, iconSizeClass) + "</span>";
    }
}