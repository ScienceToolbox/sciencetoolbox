# ScienceToolbox.org - Open research software

Science Toolbox is an index of open research software (for example [sickle by najoshi](http://sciencetoolbox.org/tools/65) or [retriever by weecology](http://sciencetoolbox.org/tools/13)). Our mission is to empower research software developers, give them the tools to measure their impact and showcase their work. Anywhere you want to (grants, CVs, reports, ...), it should be easy to include a link to your ScienceToolbox profile, where all your repositories and their impact is stored and displayed in a friendly manner.

This repository represent the Rails app powering ScienceToolbox.org's API.
Take a look at the issues for ideas on how to help.

# Importing from sources

There are several sources from which software can be imported/indexed, a very good example is the EuropePMC dataset. To import data from EuropePMC, open a console and run `Importer::EuropePmc.import`. This will loop through results on EuropePMC and add them to the database.

# Development

`vagrant up` and navigate to http://10.4.4.4:3000 to start developing.

