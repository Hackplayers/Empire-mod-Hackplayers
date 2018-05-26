from lib.common import helpers

class Module:

    def __init__(self, mainMenu, params=[]):

        # metadata info about the module, not modified during runtime
        self.info = {
            # name for the module that will appear in module menus
            'Name': 'PowerCat',

            # list of one or more authors for the module
            'Author': ['besimorhino'],

            # more verbose multi-line description of the module
            'Description': ('powercat is a powershell function. First you need to load the function before you can execute it.'
                            'You can put one of the below commands into your powershell profile so powercat is automatically'
			    'loaded when powershell starts..'),
            # True if the module needs to run in the background
            'Background' : True,

            # File extension to save the file as
            'OutputExtension' : None,

            # True if the module needs admin rights to run
            'NeedsAdmin' : False,

            # True if the method doesn't touch disk/is reasonably opsec safe
            'OpsecSafe' : True,
            
            'Language' : 'powershell',

            'MinLanguageVersion' : '2',

            # list of any references/other comments
            'Comments': [
                'comment',
                'https://github.com/besimorhino/powercat'
            ]
        }

        # any options needed by the module, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
			'Agent' : {
                'Description'   :   'Agent to run module on.',
                'Required'      :   True,
                'Value'         :   ''
            },
            'l' : {
                'Description'   :   'Switch. Listen for a connection',
                'Required'      :   False,
                'Value'         :   ''
            },
            'c' : {
                'Description'   :   'Connect to a listener',
                'Required'      :   False,
                'Value'         :   ''
            },
            'p' : {
                'Description'   :   'The port to connect to, or listen on.',
                'Required'      :   False,
                'Value'         :   ''            
            },
            'e' : {
                'Description'   :   'Execute. (GAPING_SECURITY_HOLE) ',
                'Required'      :   False,
                'Value'         :   ''
            },
            'ep' : {
                'Description'   :   'Switch. Execute Powershell.',
                'Required'      :   False,
                'Value'         :   ''
            },
            'r' : {
                'Description'   :   'Switch. Relay. Format: -r tcp:10.1.1.1:443',
                'Required'      :   False,
                'Value'         :   ''
            },
			'u' : {
                'Description'   :   'Switch. Transfer data over UDP.',
                'Required'      :   False,
                'Value'         :   ''
            },
			'u' : {
                'Description'   :   'Switch. Transfer data over UDP.',
                'Required'      :   False,
                'Value'         :   ''
            },
			'dns' : {
                'Description'   :   'Transfer data over dns (dnscat2).',
                'Required'      :   False,
                'Value'         :   ''
            },
			'dnsft' : {
                'Description'   :   'DNS Failure Threshold. ',
                'Required'      :   False,
                'Value'         :   ''
            },
			't' : {
                'Description'   :   'Timeout option. Default: 60 ',
                'Required'      :   False,
                'Value'         :   ''
            },
			'i' : {
                'Description'   :   'Input: Filepath (string), byte array, or string.',
                'Required'      :   False,
                'Value'         :   ''
            },
			'o' : {
                'Description'   :   'Console Output Type: "Host", "Bytes", or "String" ',
                'Required'      :   False,
                'Value'         :   ''
            },
			'of' : {
                'Description'   :   'Output File Path.  ',
                'Required'      :   False,
                'Value'         :   ''
            },
			'd' : {
                'Description'   :   'Switch. Disconnect after connecting.',
                'Required'      :   False,
                'Value'         :   ''
            },
			'rep' : {
                'Description'   :   'Switch. Repeater. Restart after disconnecting.',
                'Required'      :   False,
                'Value'         :   ''
            },
			'g' : {
                'Description'   :   'Switch. Generate Payload',
                'Required'      :   False,
                'Value'         :   ''
            },
			'ge' : {
                'Description'   :   'Switch. Generate Encoded Payload',
                'Required'      :   False,
                'Value'         :   ''
            }
                    
        }

        # save off a copy of the mainMenu object to access external functionality
        #   like listeners/agent handlers/etc.
        self.mainMenu = mainMenu

        # During instantiation, any settable option parameters
        #   are passed as an object set to the module and the
        #   options dictionary is automatically set. This is mostly
        #   in case options are passed on the command line
        if params:
            for param in params:
                # parameter format is [Name, Value]
                option, value = param
                if option in self.options:
                    self.options[option]['Value'] = value


    def generate(self, obfuscate=False, obfuscationCommand=""):
        
        # the PowerShell script itself, with the command to invoke
        #   for execution appended to the end. Scripts should output
        #   everything to the pipeline for proper parsing.
        #
        # the script should be stripped of comments, with a link to any
        #   original reference script included in the comments.
        script = """
"""


        # if you're reading in a large, external script that might be updates,
        #   use the pattern below
        # read in the common module source code
        moduleSource = self.mainMenu.installPath + "/data/module_source/management/powercat.ps1"
        try:
            f = open(moduleSource, 'r')
        except:
            print helpers.color("[!] Could not read module source path at: " + str(moduleSource))
            return ""

        moduleCode = f.read()
        f.close()

        script = moduleCode
	scriptEnd = "powercat"


        # add any arguments to the end execution of the script
        for option,values in self.options.iteritems():
            if option.lower() != "agent":
                if values['Value'] and values['Value'] != '':
                    if values['Value'].lower() == "true":
                        # if we're just adding a switch
                        scriptEnd += " -" + str(option)
                    else:
                        scriptEnd += " -" + str(option) + " " + str(values['Value'])
        if obfuscate:
            scriptEnd = helpers.obfuscate(self.mainMenu.installPath, psScript=scriptEnd, obfuscationCommand=obfuscationCommand)
        script += scriptEnd
        return script