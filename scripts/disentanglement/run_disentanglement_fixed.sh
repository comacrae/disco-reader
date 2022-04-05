#!/bin/bash

inputs=( ../../data/golang/Nov2019-Jan2020/golang_Nov2019-Jan2020.xml \
../../data/golang/Feb2020-Apr2020/golang_Feb2020-Apr2020.xml \
../../data/golang/May2020-July2020/golang_May2020-Jul2020.xml \
../../data/golang/Aug2020-Sep2020/golang_Aug2020-Sep2020.xml \
../../data/clojurians/Nov2019-Jan2020/clojure_Nov2019-Jan2020.xml \
../../data/clojurians/Feb2020-Apr2020/clojure_Feb2020-Apr2020.xml \
../../data/clojurians/May2020-July2020/clojure_May2020-Jul2020.xml \
../../data/clojurians/Aug2020-Oct2020/clojure_Aug2020-Oct2020.xml \
../../data/racketgeneral/Nov2019-Jan2020/racketgeneral_Nov2019-Jan2020.xml \
../../data/racketgeneral/Feb2020-Apr2020/racketgeneral_Feb2020-Apr2020.xml \
../../data/racketgeneral/May2020-July2020/racketgeneral_May2020-Jul2020.xml \
../../data/racketgeneral/Aug2020-Oct2020/racketgeneral_Aug2020-Oct2020.xml \
../../data/pythongeneral/Nov2019/pythongeneralNov2019.xml \
../../data/pythongeneral/Dec2019/pythongeneralDec2019.xml \
../../data/pythongeneral/Jan2020/pythongeneralJan2020.xml \
../../data/pythongeneral/Feb2020/pythongeneralFeb2020.xml \
../../data/pythongeneral/Mar2020/pythongeneralMar2020.xml \
../../data/pythongeneral/Apr2020/pythongeneralApr2020.xml \
../../data/pythongeneral/May2020/pythongeneralMay2020.xml \
../../data/pythongeneral/Jun2020/pythongeneralJun2020.xml \
../../data/pythongeneral/July2020/pythongeneralJul2020.xml \
../../data/pythongeneral/Aug2020/pythongeneralAug2020.xml \
../../data/pythongeneral/Sep2020/pythongeneralSep2020.xml \
../../data/pythongeneral/Oct2020/pythongeneralOct2020.xml
)

#in_unigrams='elsner-charniak-08-mod/data/linux-unigrams.dump'
in_unigrams='corpora/unigram.txt'

in_techwords='elsner-charniak-08-mod/data/techwords.dump'
predictions_file_name='predictions'
max_sec='1477'


export PYTHONHASHSEED=0
export PYTHONPATH=.
export PYTHONPATH=$PYTHONPATH:$PWD/elsner-charniak-08-mod
export PYTHONPATH=$PYTHONPATH:$PWD/elsner-charniak-08-mod/analysis
export PYTHONPATH=$PYTHONPATH:$PWD/elsner-charniak-08-mod/utils
export PYTHONPATH=$PYTHONPATH:$PWD/elsner-charniak-08-mod/viewer
export PATH=$PATH:$PWD/elsner-charniak-08-mod/megam_0.92


for ((i=0; i<${#inputs[@]}; i++))
do 
	echo '*** slack-specific preprocessing'
	python3 preprocessing/preprocessChat.py -o ${inputs[$i]}.pre -i ${inputs[$i]} -n preprocessing/names.txt

	echo '*** extracting features'
	rm -fR ${inputs[$i]}.dir
	python2.7 elsner-charniak-08-mod/model/classifierTest.py corpora/training.annot ${inputs[$i]}.pre $in_unigrams $in_techwords ${inputs[$i]}.dir

	##if [ ! -e elsner-charniak-08-mod/megam_0.92/megam ]; then
	echo '*** using randomforest instead of megam'
	python3 randomforest/doRandomForest.py ${inputs[$i]}.dir/$max_sec
	##fi

	echo '*** running greedy.py'
	python2.7 elsner-charniak-08-mod/model/greedy.py ${inputs[$i]}.pre ${inputs[$i]}.dir/$max_sec/$predictions_file_name ${inputs[$i]}.dir/$max_sec/devkeys > ${inputs[$i]}.dnt

	echo '*** reverting preprocessing'
	python3 postprocessing/revert_preprocessing.py ${inputs[$i]}.dnt ${inputs[$i]} ${inputs[$i]}.out
done	
