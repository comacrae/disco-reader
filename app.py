import streamlit as st
from reader import DISCO_Reader as reader
if 'reader' not in st.session_state:
    st.session_state['reader'] = reader()

#sidebar 
sidebar = st.sidebar.radio('Options:', ["File IO", "Annotate", "View Data"])

if sidebar == "File IO":
    filepath = st.text_input("Enter filepath",
            "./data/golang/Aug2020-Sep2020/golang_Aug2020-Sep2020.xml.out")

    #update filepath
    if 'filepath' not in st.session_state:
        st.session_state['filepath'] = filepath
        st.session_state['reader'].load_xml(filepath)
    elif st.session_state['filepath'] != filepath:
        try:
            st.session_state['filepath'] = filepath
            st.session_state['reader'].load_xml(filepath)
        except Exception as e:
            st.write(e)

    #set output path
    output_path= st.text_input("Enter output path", "./output.json")
    if 'output_path' not in st.session_state:
        st.session_state['output_path'] = output_path
        st.session_state['reader'].set_output_path(output_path)
    elif st.session_state['output_path'] != output_path:
        try:
            st.session_state['output_path'] = output_path
            st.session_state['reader'].load_xml(filepath)
        except Exception as e:
            st.write(e)

    #set regex

    regex= st.text_input("Enter regex to search messages for", "stackoverflow.com")
    search = st.button("Search")
    if search:
        st.session_state['regex'] = regex
        st.session_state['reader'].find_so_posts(regex)
        st.write("Search complete")
        st.write(st.session_state['reader'].get_so_posts())

    # show outputs
    st.write(f"FILEPATH: {st.session_state['filepath']}")
    st.write(f"OUTPUT_PATH: {st.session_state['output_path']}")

    json = st.button("Export Data to JSON")
    #data_type = st.radio("Data Type", ["Convo threads", "Match Convo Threads", "Both"])
    if json:
        st.session_state['reader'].export_to_json()
        st.write("Exported data to {st.session_state['output_path']}")

if sidebar == "Annotate": 
    conversation_id = 1
    col1,col2 = st.columns(2)
    c = st.empty()
    if 'regex' not in st.session_state:
        c.write("Warning: Must generate SO post searches in File IO tab")
    else:
        conversation_id = st.select_slider("Conversation ID", 
                        options=st.session_state['reader'].get_so_convo_ids()
        )
    start = st.button("Go to Conversation")
    if start:
        if self.session_state is not None:
            convo_id = self.session_state['convo_id']
            msg_idx = self.session_state['msg_idx']
        else:
            convo_id = conversation_id
            msg_idx = 0
        full_convo = st.session_state['reader'].get_convo(int(convo_id))
        so_convo = st.session_state['reader'].get_so_convo(int(convo_id))
        c.table(st.session_state['reader'].get_convo_df(msg, full_convo))
        next_button = st.button("next")
        if next_button:
                self.message_index+=1
    #inputs = st.columns(4)


if sidebar == "View Data":
    col1,col2,col3=st.columns(3)
    full_msg = col1.button("All Messages") 
    matches = col2.button("Matches")
    meta = col3.button("Metadata")
    c = st.empty()
    if full_msg:
        c.dataframe(st.session_state['reader'].get_data_dict())
    if matches:
        c.dataframe(st.session_state['reader'].get_so_data_dict())
    if meta:
        c.dataframe(st.session_state['reader'].get_meta_data_dict())
