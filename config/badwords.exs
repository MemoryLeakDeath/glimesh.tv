use Mix.Config

#
#
#                 ░░░░
#                                             ██
#                                           ██░░██
#   ░░          ░░                        ██░░░░░░██                            ░░░░
#                                       ██░░░░░░░░░░██
#                                       ██░░░░░░░░░░██
#                                     ██░░░░░░░░░░░░░░██
#                                   ██░░░░░░██████░░░░░░██
#                                   ██░░░░░░██████░░░░░░██
#                                 ██░░░░░░░░██████░░░░░░░░██
#                                 ██░░░░░░░░██████░░░░░░░░██
#                               ██░░░░░░░░░░██████░░░░░░░░░░██
#                             ██░░░░░░░░░░░░██████░░░░░░░░░░░░██
#                             ██░░░░░░░░░░░░██████░░░░░░░░░░░░██
#                           ██░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░██
#                           ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██
#                         ██░░░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░░░██
#                         ██░░░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░░░██
#                       ██░░░░░░░░░░░░░░░░░░██████░░░░░░░░░░░░░░░░░░██
#         ░░            ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██
#                         ██████████████████████████████████████████
#                      THIS FILE CONTAINS VERY RUDE & INSENSITIVE WORDS.
#                      THE INTENTION IS TO FILTER OUT BAD INTENTIONS OF
#                      OUR USERS, PLEASE TURN BACK NOW IF YOU NEED TO!
#                   ░░
#
#


config :glimesh,
  reserved_words: [
    # Glimesh-specific
    "discover", "following", "events", "community", "network", "communities", "networks", "storage", "css", "js",
    "webfonts", "img", "avatars", "glimesh", "team",

    # Generic
    "about", "access", "account", "accounts", "add", "address", "adm", "admin", "administration", "adult",
    "advertising", "affiliate", "affiliates", "ajax", "analytics", "android", "anon", "anonymous", "api",
    "app", "apps", "archive", "atom", "auth", "authentication", "avatar", "backup", "banner", "banners", "bin",
    "billing", "blog", "blogs", "board", "bot", "bots", "business", "chat", "cache", "cadastro", "calendar",
    "campaign", "careers", "cgi", "client", "cliente", "code", "comercial", "compare", "config", "connect",
    "contact", "contest", "create", "code", "compras", "css", "dashboard", "data", "db", "design", "delete",
    "demo", "design", "designer", "dev", "devel", "dir", "directorydoc", "docs", "domain", "download", "downloads",
    "edit", "editor", "email", "ecommerce", "forum", "forums", "faq", "favorite", "feed", "feedback", "flog",
    "follow", "file", "files", "free", "ftpgadget", "gadgets", "games", "guest", "group", "groups", "help",
    "home", "homepage", "host", "hosting", "hostname", "html", "http", "httpd", "https", "hpg", "info",
    "information", "image", "img", "images", "imap", "index", "invite", "intranet", "indice", "ipad", "iphone",
    "irc", "java", "javascript", "job", "jobs", "js", "knowledgebase", "log", "login", "logs", "logout", "list",
    "lists", "mail", "mail1", "mail2", "mail3", "mail4", "mail5", "mailer", "mailing", "mx", "manager", "marketing",
    "master", "me", "media", "message", "microblog", "microblogs", "mine", "mp3", "msg", "msn", "mysql", "messenger",
    "mob", "mobile", "movie", "movies", "music", "musicas", "my", "name", "named", "net", "network", "new", "news",
    "newsletter", "nick", "nickname", "notes", "noticias", "ns", "ns1", "ns2", "ns3", "ns4", "old", "online",
    "operator", "order", "orders", "page", "pager", "pages", "panel", "password", "perl", "pic", "pics", "photo",
    "photos", "photoalbum", "php", "plugin", "plugins", "pop", "pop3", "post", "postmaster", "postfix", "posts",
    "profile", "project", "projects", "promo", "pub", "public", "python", "random", "register", "registration",
    "root", "ruby", "rss", "sale", "sales", "sample", "samples", "script", "scripts", "secure", "send", "service",
    "shop", "sql", "signup", "signin", "search", "security", "settings", "setting", "setup", "site", "sites",
    "sitemap", "smtp", "soporte", "ssh", "stage", "staging", "start", "subscribe", "subdomain", "suporte",
    "support", "stat", "static", "stats", "status", "store", "stores", "system", "tablet", "tablets", "tech",
    "telnet", "test", "test1", "test2", "test3", "teste", "tests", "theme", "themes", "tmp", "todo", "task",
    "tasks", "tools", "tv", "talk", "update", "upload", "url", "user", "username", "usuario", "usage", "vendas",
    "video", "videos", "visitor", "win", "ww", "www", "www1", "www2", "www3", "www4", "www5", "www6", "www7",
    "wwww", "wws", "wwws", "web", "webmail", "website", "websites", "webmaster", "workshop", "xxx", "xpg", "you",
    "yourname", "yourusername", "yoursite", "yourdomain"],
 # bad_words: [
 #   "۞", "卐", "︻╦╤─", "@$$", "ahole", "amcik", "andskota" "anus", "arschloch", "arse", "ash0le", "ash0les", "asholes",
 #   "ass", "ass monkey", "assface", "asshole", "assholes", "assh0le", "assh0lez", "assholez", "assmuncher", "asshopper",
 #   "assjacker", "asslick", "asslicker", "asswipe", "ahole","ah0le", "amcik", "andskota", "arschloch", "anus", "anal", "arse", "ballsack", "balls",
 #   "bastard", "bitch", "biatch", "bloody", "blowjob", "bollock", "bollok", "boner", "boob", "bugger", "bum", "butt",
 #   "buttplug", "clitoris", "cock", "coon", "crap", "cum", "cumbucket", "cunt", "damn", "dick", "dickbag", "dildo", 
 #   "dyke", "fag", "feck", "fellate", "fellatio", "felching",
 #   "fuck", "fuckwad", "fudgepacker", "fudge", "packer", "flange", "goddamn", "god", "damn", "hell", "homo", "jerk", "jizz",
 #   "knobend", "knob", "labia", "muff", "motherfucker", "nigger", "n1gger", "nigglet", "nigga", "n1gga", "penis",
 #   "piss", "poop", "prick", "pube", "pussy", "queer", "queef", "scrotum", "sex", "shit", "shite", "sh1t",
 #   "shithead", "sloot", "slut", "smegma", "spunk", "tit", "titty", "titty-licker"
 #   "tosser", "turd", "twat", "vagina", "wank", "whore", "wtf"

  bad_words: [

    "۞", "۩", "ஜ", "卐", "︻╦╤─", "@$$", "..l..", "..i..", "..I..", "..|..", "ahole", "amcik", "andskota", "anus", "arschloch", "arse", "ash0le","ash0les", #Hate Speech Present
    "asholes", "ass", "ass monkey", "assface", "assh0le", "assh0lez", "asshole", "assholes", "assholz", "asshopper", 
    "assjacker", "asslick", "asslicker", "assmonkey", "assmunch", "assmuncher", "assnigger", "asspirate", "assrammer",
    "assshit", "assshole", "asssucker", "asswad", "asswipe", "axwound", "ayir", "azzhole", "b\!\+ch", "b\!tch", "b00bs",
    "b17ch", "b1tch", "bassterds", "bastard", "bastard", "bastardz", "basterds", "basterdz", "basturds", "bi\+ch", "bi7ch",
    "Biatch", "bitch", "bitches", "blow job", "blowjob", "boffing", "boiolas", "bollock", "boobs", "breasts", "buceta", "butt"
    "butt-pirate", "butthole", "buttlicker", "buttwipe", "c0ck", "c0cks", "c0k", "cabron", "caca", "carpetmuncher", "carpetmuncha", #particularly nasty ones
    "carpet muncher", "cawk", "cawks", "cazzo", "chink", "chraa", "chuj", "cipa" "clit", "clits", "cnts", "cntz", "cock",
    "cock-head", "cock-sucker", "cockhead", "cocks", "cocksucker", "crap", "cum", "cunt", "cunts", "cunty", "cuntz", "d4mn", "dab",
    "damn", "daygo", "dego", "dick", "dicksucker", "dicklicker", "dickfucker", "dike", "dild0", "dild0s", "dildo", "dildos", "dilld0",
    "dilld0s", "dirsa", "dominatricks", "dominatrics", "dominatrix", "dupa", "dyke", "dziwka", "ejackulate", "ejakulate", "Ekrem",
    "ekto", "enculer", "enema", "f u c k", "f u c k e r", "faen", "fag", "fag1t", "faget", "fagg1t", "faggit", "faggot", "fagit", "fags", #Hate Speech Present
    "fagz", "faig", "faigs", "fanculo", "fanny", "fart", "fatass", "fcuk", "feces" "feg", "Felcher", "ficken", "fiddler", "fitt", 
    "flikker", "flipping the bird", "fokken", "foreskin", "fotze", "fu\(", "fuck", "fucker", "fuckin", "fucking", "fucks","fudge packer",
    "fuk", "Fukah", "fuken", "fuker", "fukin", "fukk", "fukkah", "fukken", "fukker", "fukkin", "futkretzn", "fux0r", "g00k", 
    "gay","gayboy","gayboi","gaygirl", "gaygurl", "gays", "gayz", "god-damned", "gook", "guiena", "h00r", "h0ar", "h0r", "h0re", "h4x0r", #Hate Speech Present
    "hell", "hells", "helvete", "hoar", "hoer", "homo", "homosexual", "honkey", "hoor", "hoore", "hore", "huevon", "hui", "idiot", #Hate Speech and super mild words
    "injun", "islamophobe", "jackoff", "jap", "japs", "jerk-off", "jisim", "jism", "jiss", "jizm", "jizz", "jizzbucket", "kanker",
    "kawk","kiddy", "kike", "klootzak", "knobz", "knulle", "kraut", "kuk", "kuksuger", "kunt", "kunts", "kuntz", "kurac", "kurwa",
    "kusi", "kyrpa", "l3i\+ch", "l3itch", "ladyboy", "lesbian", "lesbo", "lezzian", "lipshits", "lipshitz", "mamhoon", "maso", "masochist",
    "masokist", "massterbait", "masstrbait", "masstrbate", "masterb8", "masterbaiter", "masterbat", "masterbat3", "masterbate", "masterbates",
    "masturbat", "masturbate", "merd", "mibun", "mofo", "mong", "monkleigh", "motha fucker", "motha fuker", "motha fukkah", "motha fukker",
    "mother fucker", "mother fukah", "mother fuker", "mother fukkah", "mother fukker", "mother-fucker", "motherfucker", "mouliewop", "muie",
    "mulkku", "muschi", "mutha fucker", "mutha fukah", "mutha fuker", "mutha fukkah", "mutha fukker", "n1gr", "nastt", "nazi", "nazis", #Hate Speech Present
    "nepesaurio", "nibba", "nigg", "nigga", "nigger", "nigur", "niiger", "niigr", "nob", "nonce", "nutsack", "orafis", "orgasim", "orgasm",
    "orgasum", "oriface", "orifice", "orifiss", "orospu", "p0rn", "packi", "packie", "packy", "paki", "pakie", "paky", "paska", "pecker", "pedo", #Hate Speech Present
    "peeenus", "peeenusss", "peenus", "peinus", "pen1s", "penas" "penis", "penis-pufer", "penis puffer", "penis pufer", "penis-breath", 
    "penis huffer", "penis sucker","penus","penuus", "perse", "phuc", "phuck", "phuk", "phuker", "phukker", "picka", "pierdol", "pillu",
    "pimmel", "pimpis", "piss", "piss drinker", "pizda", "polac", "polack", "polak", "poloc", "poonani", "poontsee", "porn", "pr0n", 
    "pr1c", "pr1ck", "pr1k", "preteen", "pula", "pule", "pusse", "pussee", "pussmucher", "pussy", "pussy licker", "puta", "puto", "puuke",
    "puuker", "qahbeh", "queef", "queer", "queers", "queerz", "qweers", "qweerz", "qweir", "racist", "rautenberg", "recktum", "rectum",
    "retard", "s\.o\.b\.", "sadist", "scank", "schaffer", "scheiss", "schlampe", "schlong", "schmuck", "screw", "screwing", "scrotum",
    "semen", "sex", "sexy", "sh\!\+", "Sh\!t", "sh1t", "sh1ter", "sh1ts", "sh1tter", "sh1tz", "sharmuta", "sharmute", "shemale", "shi\+",
    "shipal", "shit", "shits", "shitter", "shitty", "Shity", "shitz", "shiz", "shyt", "shyte", "shytty", "shyty", "skanck", "skank",
    "skankee", "skankey", "skanks", "skanky", "skrib", "slut", "sluts", "slutty", "slutz", "sloot", "smut", "sod", "son-of-a-bitch",
    "teets", "teez", "testical", "testicle", "tit", "tits", "titt", "turd", "twat", "va1jina", "vag1na", "vagiina", "vagina", "vaj1na",
    "vajina", "vullva", "vulva", "w00se", "w0p", "wank", "wanka", "wanker", "wh00r", "wh0re", "whoar", "whore", "willy", "xrated", "xxx",
    "xxx\?", "$uck", "2 girls 1 cup", "2g1c", "420", "4r5e","5h1t", "5hit", "5uck", "666", "a$$","a$$hole", "a2m", "a54", "a55", "a55hole",
    "abbo", "acrotomophilia", "aeolus", "alabama hot pocket", "alaskan pipeline", "alligatorbait", "anal", "anal impaler","anal leakage",
    "analannie", "analprobe", "analsex", "anilingus", "apeshit", "ar5e", "areola", "areole", "arian", "arrse", "arsehole", "aryan", "ass fuck",
    "ass hole", "ass-fucker", "ass-hat", "ass-jabber", "ass-pirate", "assbag", "assbagger", "assbandit", "assbang", "assbanged", "assbanger", 
    "assbangs", "assbite", "assblaster", "assclown", "asscock", "asscowboy", "asscracker", "asses", "assfaces", "assfuck", "assfucker",
    "assfukka", "assgoblin", "asshat", "asshead", "assho1e","asshore", "assjockey", "asskiss", "asskisser", "assklown", "asslover","assman",
    "assmaster", "assmucus", "asspacker", "asspirate", "assranger", "asswhole", "asswhore", "asswipes", "auto erotic", "autoerotic",
    "azazel", "azz", "a_s_s", "b u t t h o l e", "b!tch", "babe", "babeland", "babes", "baby batter", "baby juice", "badfuck", "ball gag",
    "ball gravy", "ball kicking", "ball licking", "ball sack", "ball sucking", "ballbag", "balllicker", "balls", "ballsack", "bampot",
    "bang", "bang (one's) box", "bangbros", "banger", "bareback", "barely legal", "barelylegal", "barenaked", "barenekkid", "barf", "bastardo",
    "bastinado", "batty boy", "bawdy", "bazooms", "bbw", "bdsm", "beaner", "beaners", "beardedclam", "beastality", "beastial", "beastiality",
    "beat-off", "beatch", "beater", "beatoff", "beatyourmeat", "beaver", "beaver cleaver", "beaver lips", "beef curtain", "beef curtains",
    "beeyotch", "bellend", "beotch", "bescumber", "bestiality", "bi+ch", "big black", "big breasts", "big knockers", "big tits", "bigass",
    "bigbastard", "bigbutt", "bigtits", "bimbo", "bimbos", "bint", "birdlock", "bitch tit", "bitch tits", "bitchass", "bitched", "bitcher",
    "bitchers", "bitchez", "bitchin", "bitching", "bitchslap", "bitchtits", "bitchy", "black cock", "blonde action", "blonde on blonde action",
    "bloodclaat", "bloody hell", "blow", "blow me", "blow mud", "blow your load", "blowjobs", "blue waffle", "blumpkin", "boang", "bod", "bodily", 
    "bogan", "bohunk", "boink", "bollick", "bollocks", "bollok", "bollox", "bondage", "boned", "boner", "boners", "bong", "boob", "boobies",
    "booby", "boody", "booger", "bookie", "boondoggle", "boong", "boonga", "boonie", "booobs", "boooobs", "booooobs", "booooooobs", "bootee", 
    "bootie", "booty call", "bootycall", "booze", "boozer", "boozy", "bosom", "bosomy", "bountybar", "bowel", "bowels", "bra", "brassiere",
    "breast", "breeder", "brotherfucker", "brown showers", "brunette action", "bugger", "bukkake", "bull shit", "bulldike", "bulldyke",
    "bullet vibe", "bullshit", "bullshits", "bullshitted", "bullturds", "bum", "bum boy", "bumblefuck", "bumclat", "bumfuck", "buncombe",
    "bung", "bung hole", "bunghole", "bunny fucker", "bust a load", "busty", "butchbabes", "butchdike", "butchdyke", "butt fuck", "butt plug",
    "butt-bang", "butt-fuck", "butt-fucker", "butt-fuckers", "buttbang", "buttcheeks", "buttface", "buttfuck", "buttfucka", "buttfucker", 
    "buttfuckers", "butthead", "buttman", "buttmuch", "buttmunch", "buttmuncher", "buttpirate", "buttplug", "buttstain", "byatch", "c-0-c-k",
    "c-o-c-k", "c-u-n-t", "c.0.c.k", "c.o.c.k.", "c.u.n.t", "c0cksucker", "cacafuego", "cahone", "camel toe", "cameljockey", "cameltoe","camgirl",
    "camslut", "camwhore", "carpetmuncher", "carruth", "cervix", "cherrypopper", "chesticle", "chi-chi man", "chick with a dick", "chickslick",
    "child-fucker", "chinc", "chincs", "chinky", "choad", "choade", "choc ice", "chocolate rosebuds", "chode", "chodes", "chota bags", "circlejerk",
    "cl1t", "clamdigger", "clamdiver", "cleveland steamer", "climax", "clit licker", "clitface", "clitfuck", "clitoris", "clitorus", "clitty",
    "clitty litter", "clogwog", "clover clamps", "clunge", "clusterfuck", "cnut", "cocain", "cocaine", "coccydynia", "cock pocket","cock snot",
    "cock sucker", "cockass", "cockbite", "cockblock", "cockblocker", "cockburger", "cockcowboy", "cockeye", "cockface", "cockfight", "cockfucker",
    "cockholster", "cockjockey", "cockknob", "cockknocker", "cockknoker", "cocklicker", "cocklover", "cocklump", "cockmaster", "cockmongler",
    "cockmongruel", "cockmonkey", "cockmunch", "cockmuncher", "cocknob", "cocknose", "cocknugget", "cockqueen", "cockrider", "cockshit", "cocksman",
    "cocksmith", "cocksmoke", "cocksmoker", "cocksniffer", "cocksucer", "cocksuck", "cocksucked", "cocksuckers", "cocksucking", "cocksucks", "cocksuka",
    "cocksukka", "cocktail", "cocktease", "cockwaffle", "coffin dodger", "coital", "coitus", "cok", "cokmuncher", "coksucka", "commie", "condom", "coochie",
    "coochy", "coon", "coondog", "coonnass", "coons", "cooter", "cop some wood", "coprolagnia", "coprophilia", "corksucker", "cornhole", "corp whore",
    "corpulent", "cox", "crabs", "crack", "crack-whore", "cracker", "crackpipe", "crackwhore", "creampie", "cripple", "crotchjockey", "crotchmonkey",
    "crotchrot", "crotte", "cum chugger", "cum dumpster", "cum freak", "cum guzzler", "cumbubble", "cumdump", "cumdumpster", "cumfest", "cumguzzler",
    "cumjockey", "cumm", "cummer", "cummin", "cumming", "cumqueen", "cums", "cumshot", "cumshots", "cumslut", "cumstain", "cumtart", "cunilingus",
    "cunillingus", "cunnie", "cunnilingus", "cunntt", "cunny", "cunt hair", "cunt-struck", "cuntass", "cuntbag", "cunteyed", "cuntface", "cuntfuck",
    "cuntfucker", "cunthole", "cunthunter", "cuntlick", "cuntlicker", "cuntlicking", "cuntrag", "cuntsicle", "cuntslut", "cuntsucker", "cus", "cut rope",
    "cyalis", "cyberfuc", "cyberfuck", "cyberfucked", "cyberfucker", "cyberfuckers", "cyberfucking", "cybersex", "cyberslimer", "d0ng", "d0uch3", "d0uche",
    "d1ck", "d1ld0", "d1ldo", "dabb", "dago", "dagos", "dammit", "damnation", "damned", "damnit", "darkie", "date rape", "daterape", "datnigga", "dawgie-style",
    "deapthroat", "deep throat", "deepthroat", "deggo", "dendrophilia", "dick head", "dick hole", "dick shy", "dick-ish", "dick-sneeze", "dickbag",
    "dickbeaters", "dickbrain", "dickdipper", "dickface", "dickflipper", "dickforbrains", "dickfuck", "dickfucker", "dickhead", "dickheads", "dickhole",
    "dickish", "dickjuice", "dickless", "dicklick", "dicklicker", "dickman", "dickmilk", "dickmonger", "dickripper", "dicks", "dicksipper", "dickslap",
    "dicksucker", "dicksucking", "dicktickler", "dickwad", "dickweasel", "dickweed", "dickwhipper", "dickwod", "dickzipper", "diddle", "diligaf",
    "dillweed", "dimwit", "dingle", "dingleberries", "dingleberry", "dink", "dinks", "dipship", "dipshit", "dipstick", "dirty pillows", "dirty sanchez",
    "dix", "dixiedike", "dixiedyke", "dlck", "dog style", "dog-fucker", "doggie style", "doggie-style", "doggiestyle", "doggin", "dogging", "doggy style",
    "doggy-style", "doggystyle", "dolcett", "domination", "dommes", "dong", "donkey punch", "donkeypunch", "donkeyribber", "doochbag", "dookie", "doosh",
    "dopey", "double dong", "double penetration", "Doublelift", "douch3", "douche", "douche-fag", "douchebag", "douchebags", "douchewaffle", "douchey",
    "dp action", "dripdick", "drunk", "dry hump", "duche", "dumass", "dumb ass", "dumbass", "dumbasses", "dumbbitch", "dumbcunt", "dumbfuck", "dumbshit",
    "dumshit", "dvda", "dyefly", "dykes", "easyslut", "eat a dick", "eat hair pie", "eat my ass", "eatballs", "eatpussy", "ecchi", "ejaculate", "ejaculated",
    "ejaculates", "ejaculating", "ejaculatings", "ejaculation", "enlargement", "erect", "erection", "ero", "erotic", "erotism", "escort", "essohbee", "eunuch",
    "extacy", "extasy", "f a g", "f u", "f*ck", "f-u-c-k", "f.u.c.k", "f4nny", "fa/ggot", "facefucker", "facial", "fack", "fagbag", "fagfucker", "fagg", "fagged",
    "fagging", "faggitt", "faggotcock", "faggots", "faggs", "fagot", "fagots", "fagtard", "faigt", "fannybandit", "fannyflaps", "fannyfucker", "fanyy", "fartknocker",
    "fastfuck", "fatah", "fatfuck", "fatfucker", "fckcum", "fcuker", "fcuking", "fecal", "feck", "fecker", "feist", "felatio", "felch", "felching", "fellate",
    "fellatio", "feltch", "feltcher", "feltching", "female squirting", "femdom", "fenian", "fetish", "fice", "figging", "fingerbang", "fingerfood", "fingerfuck",
    "fingerfucked", "fingerfucker", "fingerfuckers", "fingerfucking", "fingerfucks", "fingering", "fist fuck", "fisted", "fister", "fistfuck", "fistfucked", 
    "fistfucker", "fistfuckers", "fistfucking", "fistfuckings", "fistfucks", "fisting", "fisty", "flamer", "flange", "flaps", "fleshflute", "flog the log",
    "floozy", "foad", "foah", "fondle", "foobar", "fook", "fooker", "foot fetish", "footaction", "footfuck", "footfucker", "footjob", "footlicker", "footstar",
    "freakfuck", "freakyfucker", "freefuck", "frenchify", "frotting", "fu", "fu*k", "fubar", "fuc", "fucck", "fuck buttons", "fuck hole", "fuck off", "fuck puppet",
    "fuck trophy", "fuck yo mama", "fuck you", "fuck-ass", "fuck-bitch", "fuck-tard", "fucka", "fuckable", "fuckass", "fuckbag", "fuckboy", "fuckbrain", "fuckbuddy",
    "fuckbutt", "fuckbutter", "fucked", "fuckedup", "fuckers", "fuckersucker", "fuckface", "fuckfest", "fuckfreak", "fuckfriend", "fuckhead", "fuckheads", "fuckher",
    "fuckhole", "fuckina", "fuckingbitch", "fuckings", "fuckingshitmotherfucker", "fuckinnuts", "fuckinright", "fuckit", "fuckknob", "fuckme", "fuckmeat", "fuckmehard",
    "fuckmonkey", "fucknugget", "fucknut", "fucknutt", "fuckoff", "fuckpig", "fuckstick", "fucktard", "fucktards", "fucktart", "fucktoy", "fucktwat", "fuckup", "fuckwad",
    "fuckwhit", "fuckwhore", "fuckwit", "fuckwitt", "fuckyou", "fudge-packer", "fudgepacker", "fugly", "fuking", "fukkers", "fuks", "fukwhit", "fukwit", "funfuck", "fuq",
    "futanari", "fuuck", "fux", "fvck", "fxck", "f_u_c_k", "g a y", "g#y", "g-spot", "gae", "gai", "gang", "gang bang", "gang-bang", "gangbang", "gangbanged",
    "gangbanger", "gangbangs", "gangsta", "ganja", "gash", "gassy ass", "gatorbait", "gay sex", "gayass", "gaybob", "gaydo", "gayfuck", "gayfuckist", "gaylord",
    "gaysex", "gaytard", "gaywad", "gender bender", "genitals","getiton", "gey", "gfy", "ghay", "ghey", "ghuy'cha'", "giant cock", "gigolo", "ginger", "ginzo",
    "gipp", "gippo", "girl on top", "girls gone wild", "givehead", "glans", "goatcx", "goatse", "gob", "God damn", "god-dam", "godammit", "godamn", "godamnit",
    "goddam", "goddamit", "goddammit", "goddamn", "goddamned", "goddamnes", "goddamnit", "goddamnmuthafucker", "godsdamn", "gokkun", "golden shower", "goldenshower",
    "golliwog", "gonad", "gonads", "gonorrehea", "goo girl", "gooch", "goodpoop", "gooks", "goregasm", "gotohell", "goy", "goyim", "greaseball", "gringo", "groe",
    "grope", "grostulation", "group sex", "gspot", "gtfo", "gubba", "gucci", "gucci gang", "guido", "gummer", "guro", "gyp", "gypo", "gypp", "gyppie", "gyppo", "gyppy", #hate speech
    "h0m0", "h0mo", "ham flap", "hamas", "hand job", "handjob", "hapa", "hard core", "hard on", "hardcore", "hardcoresex", "hardon", "harem", "he-she", "headfuck",
    "hebe", "heeb", "hemp", "hentai", "heroin", "herp", "herpes", "herpy", "heshe", "hircismus", "hiscock", "hitler", "hiv", "ho", "hoare", "hobag", "hodgie", "hoe",
    "holestuffer", "holy shit", "hom0", "homey", "homo", "homobangers", "homodumbshit", "homoerotic", "homoey", "honky", "hooch", "hookah", "hooker", "hookers",
    "hootch", "hooter", "hooters", "horney", "horniest", "horny", "horseshit", "hosejob", "hot carl", "hot chick", "hotdamn", "hotpussy", "hotsex", "hottotrot",
    "how to kill", "how to murdep", "how to murder", "huge fat", "hump", "humped", "humping", "hun", "hussy", "hymen", "iap", "iberian slap", "iblowu", "inbred",
    "incest", "intercourse", "intheass", "inthebuff", "isis", "j3rk0ff", "jack off", "jack-off", "jackass", "jackasses", "jackhole", "jackshit", "jaggi", "jagoff",
    "jail bait", "jailbait", "jebus", "jelly donut", "jerk off", "jerk0ff", "jerkass", "jerked", "jerkoff", "jigaboo", "jiggaboo", "jiggerboo", "jimfish", "jiz",
    "jizim", "jizjuice", "jizzed", "jizzim", "jizzum", "jock", "juggs", "jungle bunny", "junglebunny", "junkie", "junky", "kaffer", "kaffir", "kaffre", "kafir",
    "kanake", "kikes", "kill", "kinbaku", "kinkster", "kinky", "kissass", "kkk", "klan", "knob end", "knobbing", "knobead", "knobed", "knobend", "knobhead",
    "knobjocky", "knobjokey", "kock", "kondum", "kondums", "kooch", "kooches", "kootch", "kotex", "krap", "krappy", "kum", "kumbubble", "kumbullbe", "kummer",
    "kumming", "kums", "kunilingus", "kunja", "kunnilingus", "kwif", "kyke", "l3i+ch", "labia", "lameass", "lapdance", "lardass", "leather restraint",
    "leather straight jacket", "lech", "lemon party", "leper", "lesbians", "lesbos", "lez", "lezbian", "lezbians", "lezbo", "lezbos", "lezza/lesbo", "lezzie",
    "lezzies", "lezzy", "limpdick", "livesex", "lmao", "lmfao", "loin", "loins", "lolita", "looney", "lovegoo", "lovegun", "lovejuice", "lovemaking",
    "lovemuscle", "lovepistol", "loverocket", "lube", "lubejob", "lust", "lusting", "lusty", "m-fucking", "m0f0", "m0fo", "m45terbate", "ma5terb8",
    "ma5terbate", "mafugly", "make me come", "male squirting", "mams", "manpaste", "massa", "mastabate", "mastabater", "master-bate", "masterbat*", "masterbating",
    "masterbation", "masterbations", "mastrabator", "masturbating", "masturbation", "maxi", "mcfagget", "meatbeatter", "menage a trois", "menses", "menstruate",
    "menstruation", "meth", "mgger", "mggor", "mick", "microphallus", "midget", "milf", "minge", "minger", "missionary position", "mo-fo", "mockey", "mockie",
    "mocky", "mof0", "moky", "molest", "molestation", "molester", "molestor", "moneyshot", "moo moo foo foo", "moolie", "mooncricket", "moron", "mosshead",
    "mothafuck", "mothafucka", "mothafuckas", "mothafuckaz", "mothafucked", "mothafucker", "mothafuckers", "mothafuckin", "mothafucking", "mothafuckings",
    "mothafucks", "motherfuck", "motherfucka", "motherfucked", "motherfuckers", "motherfuckin", "motherfucking", "motherfuckings", "motherfuckka", "motherfucks",
    "motherlovebone", "mound of venus", "mr hands", "mtherfucker", "mthrfucker", "mthrfucking", "muff", "muff diver", "muff puff", "muffdive", "muffdiver",
    "muffdiving", "muffindiver", "mufflikcer", "mulatto", "munging", "munt", "munter", "murder", "mutha", "muthafecker", "muthafuckaz", "muthafucker",
    "muthafuckker", "muther", "mutherfucker", "mutherfucking", "muthrfucking", "n1gga", "n1gger", "nad", "nads", "naked", "nambla", "napalm", "nappy", "narcotic",
    "nastybitch", "nastyho", "nastyslut", "nastywhore", "nawashi", "nazism", "need the dick", "negro", "neonazi", "ni66a", "nig", "nig nog", "nig-nog", "nigaboo",
    "niger", "nigg3r", "nigg4h", "niggah", "niggaracci", "niggard", "niggard's", "niggarded", "niggarding", "niggardliness", "niggardliness's", "niggardly",
    "niggards", "niggas", "niggaz", "nigger's", "niggerfaggot", "niggerhead", "niggerhole", "niggers", "niggle", "niggled", "niggles", "niggling", "nigglings",
    "niggor", "niggs", "niggur", "niglet", "nignog", "nigr", "nigra", "nigre", "nimphomania", "nimrod", "ninny", "ninnyhammer", "nipple", "nipples", "nittit",
    "nlgger", "nlggor", "nob jokey", "nobhead", "nobjocky", "nobjokey", "nofuckingway", "nooky", "noonan", "nooner", "nsfw images", "nude", "nudger", "nudity",
    "numbnuts", "nut butter", "nut sack", "nutfucker", "nutter", "nympho", "nymphomania", "octopussy", "old bag", "omg", "omorashi", "one cup two girls",
    "one guy one jar", "ontherag", "opiate", "opium", "oral", "orally", "orga", "organ", "orgasims", "orgasmic", "orgasms", "orgies", "orgy", "ovary", "ovum",
    "ovums", "p e n i s", "p.u.s.s.y.", "paddy", "paedophile", "panooch", "pansies", "pansy", "panti", "pantie", "panties", "panty", "pastie", "pasty", "pawn",
    "payo", "pcp", "peckerhead", "peckerwood", "pedobear", "pedophile", "pedophilia", "pedophiliac", "peepee", "pegging", "pendy", "penetrate", "penetration",
    "peni5", "penial", "penile", "penisbanger", "penises", "penisfucker", "penispuffer", "perversion", "peyote", "phalli", "phallic", "phone sex", "phonesex",
    "phuked", "phuking", "phukked", "phukking", "phuks", "phungky", "phuq", "picaninny", "piccaninny", "pickaninny", "piece of shit", "pigfucker", "piker",
    "pikey", "piky", "pillowbiter", "pimp", "pimped", "pimper", "pimpjuic", "pimpjuice", "pimpsimp", "pindick", "pinko", "piss off", "piss pig", "piss-off",
    "pissed", "pissed off", "pisser", "pissers", "pisses", "pissflaps", "pisshead", "pissin", "pissing", "pissoff", "pisspig", "playboy", "playgirl",
    "pleasure chest", "pms", "pocha", "pohm", "pole smoker", "polesmoker", "pollock", "pommie", "pommy", "ponyplay", "poof", "poon", "poonany", "poontang",
    "poop chute", "poopchute", "pooper", "pooperscooper", "pooping", "Poopuncher", "poorwhitetrash", "popimp", "porch monkey", "porchmonkey", "pornflick",
    "pornking", "porno", "pornography", "pornos", "pornprincess", "pot", "potty", "prick", "prickhead", "pricks", "prickteaser", "prig", "prince albert piercing",
    "prod", "pron", "prostitute", "prude", "psycho", "pthc", "pu55i", "pu55y", "pube", "pubes", "pubic", "pubis", "pud", "pudboy", "pudd", "puddboy", "punani",
    "punanny", "punany", "punkass", "punky", "punta", "puntang", "puss", "pussi", "pussie", "pussies", "pussy fart", "pussy palace", "pussycat", "pussyeater",
    "pussyfucker", "pussylicker", "pussylicking", "pussylips", "pussylover", "pussypounder", "pussys", "pust", "pusy", "p€nis", "QI'yaH", "Qu'vatlh", "quashie",
    "queaf", "queerbait", "queerhole", "queero", "quicky", "quim", "r-tard", "rabbi", "racy", "raghead", "raging boner", "rape", "raped", "raper", "rapey",
    "raping", "rapist", "raunch", "rearend", "rectal", "rectus", "redlight", "reefer", "reestie", "reetard", "reich", "renob", "rentafuck", "rere", "retarded",
    "reverse cowgirl", "revue", "rimjaw", "rimjob", "rimming", "ritard", "roblox", "rosy palm", "rosy palm and her 5 sisters", "roundeye", "rtard", "rubbish",
    "rum", "rump", "rumprammer", "ruski", "rusty trombone", "s hit", "s&m", "s-h-1-t", "s-h-i-t", "s-o-b", "s.h.i.t.", "s.o.b.", "s0b", "sadis", "sadism",
    "sadom", "sambo", "samckdaddy", "sand nigger", "sandbar", "sandler", "sandm", "sandnigger", "sanger", "santorum", "sausage queen", "scag", "scantily",
    "scat", "schizo", "scissoring", "screwed", "scroat", "scrog", "scrot", "scrote", "scrud", "scum", "seaman", "seamen", "seduce", "seks", "seppo", "sexed",
    "sexfarm", "sexhound", "sexhouse", "sexing", "sexkitten", "sexo", "sexpot", "sexslave", "sextogo", "sextoy", "sextoys", "sexual", "sexually", "sexwhore",
    "sexy-slim", "sexymoma", "sh!+", "sh!t", "shag", "shagger", "shaggin", "shagging", "shamedame", "shat", "shav", "shaved beaver", "shaved pussy", "shawtypimp",
    "sheeney", "shhit", "shi+", "shibari", "shinola", "shirt lifter", "shit ass", "shit fucker", "shitass", "shitbag", "shitbagger", "shitblimp", "shitbrains",
    "shitbreath", "shitcan", "shitcanned", "shitcunt", "shitdick", "shite", "shiteater", "shited", "shitey", "shitface", "shitfaced", "shitfit", "shitforbrains",
    "shitfuck", "shitfucker", "shitfull", "shithapens", "shithappens", "shithead", "shitheads", "shithole", "shithouse", "shiting", "shitings", "shitlist", "shitola",
    "shitoutofluck", "shitspitter", "shitstain", "shitt", "shitted", "shitters", "shittier", "shittiest", "shitting", "shittings", "shiznit", "shortfuck", "shota",
    "shout out", "shrimping", "sissy", "skag", "skankbitch", "skankfuck", "skankwhore", "skankybitch", "skankywhore", "skeet", "skinflute", "skullfuck", "skum",
    "skumbag", "slag", "slanteye", "slapper", "slaughter", "slav", "slave", "sleaze", "sleazy", "sleezebag", "sleezeball", "slideitin", "slimeball", "slimebucket", 
    "slope", "slopehead", "slut bucket", "slutbag", "slutdumper", "slutkiss", "slutt", "slutting", "slutwear", "slutwhore", "smackthemonkey", "smartass", "smartasses",
    "smeg", "smegma", "smutty", "snatch", "snatchpatch", "sniper", "snowballing", "snownigger", "snuff", "sod off", "sodom", "sodomise", "sodomite", "sodomize",
    "sodomy", "son of a bitch", "son of a motherless goat", "son of a whore", "sonofabitch", "sonofbitch", "sooty", "souse", "soused", "spac", "spade", "spaghettibender",
    "spaghettinigger", "spankthemonkey", "sperm", "spermbag", "spermhearder", "spermherder", "spic", "spick", "spig", "spigotty", "spik", "spiks", "splittail", "splooge",
    "splooge moose", "spooge", "spook", "spread legs", "spreadeagle", "spunk", "squaw", "ßuck", "steamy", "stfu", "stiffy", "stoned", "strap on", "strapon", "strappado",
    "stringer", "strip", "strip club", "stripclub", "stroke", "stroking", "stupid", "stupidfuck", "stupidfucker", "style doggy", "suck", "suckass", "suckdick", "sucked",
    "sucking", "suckme", "suckmyass", "suckmydick", "suckmytit", "suckoff", "sucks", "suicide girls", "sultry women", "sumofabiatch", "swallower", "swastika", "swinger",
    "s_h_i_t", "t1t", "t1tt1e5", "t1tties", "taff", "taig", "tainted love", "taking the piss", "tampon", "tang", "tantra", "tarbaby", "tard", "tart", "taste my", "tawdry",
    "tea bagging", "teabagging", "teat", "terd", "teste", "testee", "testes", "testicles", "testis", "thicklips", "thirdeye", "thirdleg", "threesome", "throating", "thrust",
    "thug", "thundercunt", "tied up", "tight white", "timbernigger", "tinkle", "tit wank", "titbitnipply", "titfuck", "titfucker", "titfuckin", "titi", "tities", "titjob",
    "titlicker", "titlover", "tittie", "tittie5", "tittiefucker", "titties", "titty", "tittyfuck", "tittyfucker", "tittywank", "titwank", "toke", "tongethruster",
    "tonguethrust", "tonguetramp", "toots", "topless", "tosser", "towelhead", "tramp", "tranny", "transsexual", "trashy", "tribadism", "trumped", "tub girl",
    "tubgirl", "tuckahoe", "tush", "tushy", "tw4t", "twathead", "twatlips", "twats", "twatty", "twatwaffle", "twink", "twinkie", "two fingers", "two fingers with tongue",
    "two girls one cup", "twobitwhore", "twunt", "twunter", "ugly", "unclefucker", "undies", "undressing", "unfuckable", "unwed", "upskirt", "uptheass", "upthebutt", 
    "urethra play", "urinal", "urinary", "urine", "urophilia", "uterus", "uzi", "v14gra", "v1gra", "va-j-j", "vag", "vaginal", "vajayjay", "valium", "venus mound",
    "veqtable", "viagra", "vibr", "vibrater", "vibrator", "vietcong", "violence", "violet wand", "virgin", "virginbreaker", "vixen", "vjayjay", "vodka", "vomit",
    "vorarephilia", "voyeur", "vulgar", "wab", "wad", "wang", "wanking", "wankjob", "wanky", "wazoo", "wedgie", "weed", "weenie", "weewee", "weiner", "weirdo", "welcher",
    "wench", "wet dream", "wetback", "wetspot", "wh0reface", "whacker", "whash", "whigger", "whiskeydick", "whiskydick", "white power", "whitenigger", "whitetrash",
    "whitey", "whiz", "whop", "whoralicious", "whorealicious", "whorebag", "whored", "whoreface", "whorefucker", "whorehopper", "whorehouse", "whores", "whoring",
    "wigger", "willies", "williewanker", "window licker", "wiseass", "wiseasses", "wog", "womb", "woodhouselivingpeople", "woody", "wop", "wrapping men", "wrinkled starfish",
    "wtf", "wuss", "wuzzie", "x-rated", "yaoi", "yeasty", "yellow showers", "yellowman", "yid", "yiff", "yiffy", "yobbo", "zibbi", "zigabo", "zipperhead", "zoophile",
    "zoophilia", "zubb"
  ]