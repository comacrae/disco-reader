#NOTE: THIS WORK IS NOT MY OWN. I ONLY WROTE READER.PY & APP.PY TO ANNOTATE DATA

# DISCO: A Dataset of Discord Chat Conversations for Software Engineering Research

## Overview

This repository contains Discord Q&A style conversations and code for disentangling conversations, as described in:

- K. Muthu Subash, L. Prasanna Kumar, S. Vadlamani, P. Chatterjee, O. Baysal. "DISCO: A Dataset of Discord Chat Conversations for Software Engineering Research". _submitted_

#### Data Origin: 
Discord chat channels (https://discord.com/) for four programming languages such as Python, Go (or GoLang), Racket and Clojure which demonstrate a good daily activity and a substantial number of members (e.g., Python Discord server has a total of 300, 919 members) compared to other available Discord programming servers are considered. Anyone with a Discord user ID can join these servers as they are publicly visible and start asking general or technical help questions on these channels. We identified the server channels that follow a Q&A format and offer general technical help.

#### Data Collection Process: 
For our research, we collect data in the form of whole conversations from several technology communities that are focused on getting help and learning about software-related topics, specifically on using the following technologies: python, clojure, golang, and racket. Data from the Discord channels is exported as JSON files using an open-source application, Discord Chat Exporter (https://github.com/Tyrrrz/DiscordChatExporter), with a specific date range. The date range for three channels (Python, Clojure, Racket) is from Nov-2019 to Oct-2020, while for gophers#golang the date range is Nov-2019 to Sep-2020 due to our University’s Fair Dealing Policy in using public copyrighted data for research purposes.

## Data Format

The Discord data is in XML format, with three attributes for each message: timestamp (_ts_), anonymized user id (_user_), and message _text_. The result of disentanglement, which groups utterances into conversations is provided as the _conversation_id_ attribute of each message.

```
</message>
<message conversation_id="1">
  <ts>2019-12-02T07:28:19.806000</ts>
  <user>Finley</user>
  <text>What does self and init actually mean?</text>
</message>
<message conversation_id="1">
  <ts>2019-12-02T07:32:31.919000</ts>
  <user>Abdriel</user>
  <text>When you create class you probably want to do some initialization when you create an instance of that class. That's what the special `__init__` method is for: It takes care of initializing the object when you create it.</text>
</message>
<message conversation_id="1">
  <ts>2019-12-02T07:32:52.303000</ts>
  <user>Abdriel</user>
  <text>Say I have this class:```pyclass Person: def __init__(self name): self.name = name```</text>
</message>
<message conversation_id="1">
  <ts>2019-12-02T07:33:47.942000</ts>
  <user>Abdriel</user>
  <text>Whenever I create a `Person` object I want to give it a `name`. So I want to do something like `person = Person("Ves")` or `person = Person(name="Ves")`</text>
</message>
<message conversation_id="1">
  <ts>2019-12-02T07:35:01.794000</ts>
  <user>Abdriel</user>
  <text>When you pass arguments to `Person()` (in this case `"Ves"` or `name="Ves"`) Python will (eventually) call `__init__` with those arguments</text>
</message>
<message conversation_id="1">
  <ts>2019-12-02T07:36:00.169000</ts>
  <user>Abdriel</user>
  <text>Now within a method we actually want to be able to change the object or read an attribute of the object right?</text>
</message>
<message conversation_id="1">
  <ts>2019-12-02T07:36:10.448000</ts>
  <user>Abdriel</user>
  <text>That means we need some kind of reference to the object.</text>
</message>
<message conversation_id="1">
  <ts>2019-12-02T07:36:47.250000</ts>
  <user>Abdriel</user>
  <text>In Python this is solved by the interpreter always passing the object itself as the first argument to a regular method.</text>
</message>
<message conversation_id="1">
  <ts>2019-12-02T07:37:28.684000</ts>
  <user>Abdriel</user>
  <text>The conventional name for the first parameter is `self` to signal: This name refers to the object I'm currently working with to the object itself</text>
</message>

```

Our dataset consists of approximately one year of activity from Nov-2019 to Oct-2020 (except golang which has a date range of Nov-2019 to Sep-2020) from 4 Discord channels (_python-python-general_, _clojurians-clojure_, _gophers-golang_, and _racket-general_), representing 4 Discord communities (_pythondev_, _clojurians_, _gophers_, and _racket_):

```
data
+-- clojurians
|   +-- clojureNov2019-Jan2020
|   |   +--- clojure_Nov2019-Jan2020.xml
|   +-- clojureFeb2020-Apr2020
|   |   +--- clojure_Feb2020-Apr2020.xml
|   +-- clojureMay2020-Jul2020
|   |   +--- clojure_May2020-Jul2020.xml
|   +-- clojureAug2020-Oct2020
|   |   +--- clojure_Aug2020-Oct2020.xml
+-- golang
|   +-- ...
+-- racket
|   +-- ...
+-- python
|   +-- Nov2019
|   |   +--- pythongeneralNov2019.xml
|   +-- Dec2019
|   |   +--- pythongeneralDec2019.xml
|   +-- ...
|   +-- ...
|   +-- Oct2020
|   |   +--- pythongeneralOct2020.xml

```

## Discord Scripts

We provide the Jupyter notebook file we used for processing the orginal Discord JSON format we downloaded to the simplified XML format that contains only the utterances. These scripts are in the `scripts/discord_JSON_to_XML` directory

## Disentanglement

Disentanglement scripts (based on Modified Elsner and Charniak's prior work by Chatterjee et al. on Slack data) are included in the `scripts/disentanglement` directory. Running
the *run_distantanglement.sh* shell script disentangles the XML data files. 

**Resources for Elsner and Charniak, 2008**
+ https://www.asc.ohio-state.edu/elsner.14/resources/chat-distr.tgz
+ https://www.asc.ohio-state.edu/elsner.14/resources/chat-manual.html
+ http://aclweb.org/anthology-new/J/J10/J10-3004.pdf

**List of our modifications to Elsner and Charniak as done by Chatterjee et al. for Slack data. We have used the same for Discord data**
+ changed block size from 1.5^12 to 1.5^18 
+ forced to evaluate last 5 messages regardless of timespan
+ added random forest (E&C used maximum entropy) classification for portability as results were similar
+ changed and added features, including new Slack-specific features:

1. Cue Words (Q&A conversations sometimes end with gratitude):
    + prev_thx_for_answer -- e.g., "got it", "gotcha", "makes sense", "makes perfect sense", "this works", "that works", "that worked", "seems reasonable"
    + curr_thx_for_answer
2. Code:
    + prev_code -- starts/ends with ```
    + current_code 
3. URL (answers to development related questions can be URLs):
    + prev_url
    + curr_url
4. Channel (mentions #channel in message if a message is inappropriate for the current channel):
    + prev_channel  
    + curr_channel
5. *Changed* Repeat (repeated words, weighted unigram file of (term, frequency) and k is computed as log(frequency, base=10); (new) include influence for repeated words that don't exist in the precomputed list of unigrams):
    + repeat_k  
5. *Changed* Question (existence of the '?' symbol; (new) enhanced to include the wh words):
    + curr_q 
    + prev_q

## Case Study

The LDA topic modelling case study was done on the CSV files converted from the original JSON files downloaded from the 4 channels. The Jupyter notebooks used for creating the LDA models and the Inter_topic_distance maps files (pickle, html and sourcecode files) are in the `case_study` directory.
