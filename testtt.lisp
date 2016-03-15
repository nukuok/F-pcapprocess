(defvar *temp*)

(defvar *data* (make-array 12 :initial-element 0 :element-type '(unsigned-byte 8)))
(setf *data* (cons 1 nil))
(setq (cadr *data*) (make-array 12 :initial-element 0 :element-type '(unsigned-byte 8)))
(with-open-file
    (inputfile  "20150924_2.cap" :direction :input :element-type '(unsigned-byte 8))
    (read-sequence (cdr (ip_packet-l2_header temp)) inputfile :start 0 :end 12))

(defvar *tempp*)
(setq *tempp*
      (loop
	 for (a b) in *ip-packet-format* collect
	   (format t "(~A ~x)~%" a b)))

(setq *tempp*
      (loop
	 for (a b) in *ip-packet-format* collect
	   `(,a ,b)))

(defstruct ip-packet-split
  `,@(loop
	 for (a b) in *ip-packet-format* collect
	  `(,a (cons ,b nil))))

(setq *temp* (make-ip-packet-split))
(setq *temp* (make-ips))

`(defstruct ips2
   ,@(loop
	for (a b) in *ip-packet-format* collect
	  `(,a (cons ,b nil))))

(defmacro ip-packet-split ()
`(defstruct ip-packet-split
   ,@(loop
	for (a b) in *ip-packet-format* collect
	  `(,a (cons ,b nil)))))

(defstruct abc
  (abc1 1)
  (abc2 2)
  (abc3 3))

(with-open-file
    (inputfile "20150924_2.cap" :direction :input :element-type '(unsigned-byte 8))
  (get-data inputfile 12))
	       
(when 1 (print 1))

(setf *tempp* (coerce (append (coerce "ips-" 'list) (coerce  "abc" 'list)) 'string))

(setf *tempp*
     (loop
	for (a b) in *ip-packet-format* collect
	  `(ips-,a)))
(eval `(setf (,(intern "IPS-L2_HEADER") *temp*) '(1 2)))
(eval `(setf (cadr (,(intern "IPS-L2_HEADER") *temp*)) 3))
(eval `(setf (cadr (,(intern "IPS-L2_HEADER") *temp*)) (make-array 192)))
(eval `(setq (cadr (,(intern "IPS-L2_HEADER") *temp*))
	     (make-array 3 :initial-element 0
			 :element-type '
			 (unsigned-byte 8))))
(funcall (symbol-function (intern "IPS-L2_HEADER")) *temp*)
(let ((ac (intern "IPS-L2_HEADER")))
  (print
   (funcall (symbol-function ac) *temp*)))
(loop for (a b) in *ip-packet-format* do (print (concatenate 'string "abc-" (symbol-name a))))

(with-open-file
    (inputfile "20150924_2.cap" :direction :input :element-type '(unsigned-byte 8))
  (let ((ip-packet (make-ips)))
    (loop for (a b) in *ip-packet-format* do
	 (let ((get-member-symbol (intern (concatenate 'string "IPS-" (symbol-name a)))))
	   (let ((field-length (car (funcall (symbol-function get-member-symbol) ip-packet))))
	     (when (> field-length 0)
	       (eval `(setf (cadr (,get-member-symbol ,ip-packet))
			    (make-array ,field-length
					:initial-element 0
					:element-type
					'(unsigned-byte 8))))
	       (eval `(read-requence (cadr (,get-member-symbol ,ip-packet))
				     ,inputfile :start 0 :end ,field-length)) ))))))

(let ((testt (intern "IPS-L2_HEADER")))
  (eval `(setf (cadr (,testt *temp*)) 3)))

(with-open-file
    (inputfile "20150924_2.cap" :direction :input :element-type '(unsigned-byte 8))
  (let ((ip-packet (make-ips)))
    (loop for (a b) in *ip-packet-format* do
	 (let ((get-member-symbol (intern (concatenate 'string "IPS-" (symbol-name a)))))
	   (let ((field-length (car (funcall (symbol-function get-member-symbol) ip-packet))))
	     (when (> field-length 0)
	       (eval `(setf (,get-member-symbol ip-packet)
			    (make-array ,field-length
					:initial-element 0
					:element-type
					'(unsigned-byte 8))))) )))))
;	       (eval `(read-requence (cadr (,get-member-symbol ip-packet))
;				     inputfile :start 0 :end field-length))))))))


(defmacro mk-byte-array (length)
  `(make-array ,length :initial-element 0 :element-type '(unsigned-byte 8)))

(defmacro modify-ips-ip_data (ip-packet)
  `(let ((templength (- (+ (ash (aref (cadr (ips-ip_total_length ,ip-packet)) 0) 8)
			   (aref (cadr (ips-ip_total_length ,ip-packet)) 1))
			(aref (cadr (ips-option ,ip-packet)) 0)
			20)))
     (setf (car (ips-ip_data ,ip-packet)) templength)
     (setf (cadr (ips-ip_data ,ip-packet)) (mk-byte-array templength))
     (read-sequence (cadr (ips-ip_data ,ip-packet))
		    inputfile :start 0 :end templength))))

(defmacro modify-ips-option (ip-packet)
  `(let ((templength (- (ash (logand
			      #x0f
			      (aref
			       (cadr (ips-ip_version_header_length ,ip-packet))
			       0)) 2) 20)))
     (setf (car (ips-option ,ip-packet)) templength)
     (read-sequence (cadr (ips-option ,ip-packet))
		    inputfile :start 0 :end templength)))


(with-open-file
    (inputfile "20150924_2.cap" :direction :input :element-type '(unsigned-byte 8))
  (let ((tempdata (mk-byte-array 24))) (read-sequence tempdata inputfile :start 0 :end 24))
  (dotimes (i 103)
  (let ((ip-packet (make-ips)))
    (loop for (a b) in *ip-packet-format* do
	 (let ((get-member-symbol (intern (concatenate 'string "IPS-" (symbol-name a)))))
	   (let ((field-length (car (funcall (symbol-function get-member-symbol) ip-packet))))
	     (when (> field-length 0)
	       (let ((tempdata (mk-byte-array field-length)))
		 (read-sequence tempdata inputfile :start 0 :end field-length)
		 (eval `(setf (cadr (,get-member-symbol ,ip-packet)) ,tempdata)))))
	   (when (equal (symbol-name a) "OPTION")
	     (modify-ips-option ip-packet))
	   (when (equal (symbol-name a) "IP_DATA")
	     (modify-ips-ip_data ip-packet))))
    (print ip-packet)
    (print inputfile))))
;		 (format t "~{~2,'0x ~}" (coerce tempdata 'list))
;		 (format t "~%"))))))))

D4C3B2A1204000000000FFFF001000
A27E3566B6620C2000C20
000AE484
A27E356C2662042000420
A27E356473430CA000CA0


(setf *temp* (make-array 2 :initial-contents (make-array 3 :initial-element 1)))
(subseq *temp* 0 1)

(defmacro testtt (ebc)
    `(print ,ebc))

(defmacro testt2 (ebc)
  `(progn
     (print ,ebc)
     ,(let ((atc 1))
     (eval `(print ,atc)))))

(setf *tempp* (make-tcpps))

(with-open-file
    (inputfile "20150924_2.cap" :direction :input :element-type '(unsigned-byte 8))
  (let ((tempdata (mk-byte-array 24)))
    (read-sequence tempdata inputfile :start 0 :end 24)
    (let ((ip-packet *temp*)
	  (instream inputfile))
      (ip-packet-split *temp* instream))))

(pcap-process "20150924_2.cap")


(run-program "ls" nil :output *standard-output*)



(defmacro test (a)
  `(let ((c ,a))
     (print c)))

(defmacro test (a)
  `(let ((c ,a))
     `(let ((d ,c))
	(print d))))

(defmacro test (a)
  `(let ((c ,a)
	 (cc ,a))
     `(let ((d ,,a))
	(print d))))

(defmacro test (a)
  `(let ((c ,a)
	 (cc ,a))
     `(let ((d ,cc))
	(print d))))

(defmacro test (a)
  `(let ((x ,a))
     (print x)
     (eval `(when 1
       (setf a 12)
       (print a)))
    (print x)))

(defmacro test (a)
  `(progn
     (print ,a)
     (eval `(when 1
	      (setf ,a 12)
	      (print a)))
    (print ,a)))

`(,(intern "TEST") 1)

(defun test (a)
  (progn
    (print a)
    (eval `(setf a 12))
    (print a)))
    

(defun ip-packet-split (ip-packet instream)
  (loop for (a b) in *ip-packet-format* do
	;;; a 'a
       (let ((field-length (nth 1 (assoc a ip-packet)))
	     (macro-name (concatenate 'string "MODIFY-IPS-" (symbol-name a))))
	 (when (< field-length 0)
	   (print 13321)
            ;;; a -> "a"  OPTION -> "OPTION" 
	    ;;; (,(intern (concatenate 'string "MODIFY-IPS-" (symbol-name a)))
	    ;;;  ,ip-packet)
	   (print macro-name)
	   (print (type-of macro-name))
;	   (run-macro-byname macro-name ip-packet)
	      ;;; a
	   (print field-length)
	   (print (nth 1 (assoc a ip-packet))))

(defmacro ip-packet-split (ip-packet instream)
  `(loop for (a b) in *ip-packet-format* do
	;;; a 'a
	(let ((field-length (nth 1 (assoc a ,ip-packet))))
	  (when (< field-length 0)
	    (print 13321)
             ;;; a -> "a"  OPTION -> "OPTION" 
	    (eval `(,(intern (concatenate 'string "MODIFY-IPS-" (symbol-name a)))
	      ,,ip-packet))
	      ;;; a
	    (print field-length)
	    (print (nth 1 (assoc a ,ip-packet))))
	  (read-sequence (nth 2 (assoc a ,ip-packet)) ,instream
			 :start 0 :end field-length))))

(defmacro test (a)
  (progn
    `(format t "~d ~%" ,a)
    `(setf a 12)
    `(format t "~d ~%" ,a)))

1-1-1-2.pcapng
0A0D0D0A740000004D3C2B1A01000000FFFFFFFFFFFFFFFF03001C0033322D6269742057696E646F777320382C206275696C64203932303004002F0044756D7063617020312E31302E32202853564E205265762035313933342066726F6D202F7472756E6B2D312E313029000000000074000000

010000007800000001000000FFFF0000020032005C4465766963655C4E50465F7B44414643393338462D453330442D344631442D423437422D3336414136433531383238387D000009000100060000000C001C0033322D6269742057696E646F777320382C206275696C6420393230300000000078000000

pcapng: 
06000000 block type
6C000000 block total length
00000000 interface id
56210500 timestamp (high)
AA390A68 timestramp (low)
4A000000 captured len
4A000000 packet len
000087E4 72590002 BBA8BED9 08004500 003C2B5D 0000FF01 0A0BDEE7 E447DEE7
E4410800 30C51C45 4ADB0000 00005612 25B40000 0000000A 11775A5A 5A5A5A5A
5A5A5A5A 5A5A5A5A 5A5A0000
6C000000 block total length

1-1-3-2.pcapng

0A0D0D0A740000004D3C2B1A01000000FFFFFFFFFFFFFFFF03001C0033322D6269742057696E646F777320382C206275696C64203932303004002F0044756D7063617020312E31302E32202853564E205265762035313933342066726F6D202F7472756E6B2D312E313029000000000074000000

010000009000000001000000FFFF0000020032005C4465766963655C4E50465F7B37413234303734322D334137432D343739382D413939452D3735464138383234453845337D000009000100060000000B001200006E6F742074637020706F7274203333383900000C001C0033322D6269742057696E646F777320382C206275696C6420393230300000000090000000

010000009000000001000000FFFF0000020032005C4465766963655C4E50465F7B44414643393338462D453330442D344631442D423437422D3336414136433531383238387D000009000100060000000B001200006E6F742074637020706F7274203333383900000C001C0033322D6269742057696E646F777320382C206275696C6420393230300000000090000000

060000006C000000010000006E220500D08AFD664A0000004A000000000087E472590002BBA8BED808004500003CC67E0000FF016DE9DEE7E4C7DEE7E4C10800D31941E1725D0000000056247F3800000000000AC86D5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A00006C000000

1-1-1-2.pcap
D4C3B2A1 0200 0400 00000000 00000000 00000400 01000000
B7251256EA9D0E00 4A000000 4A000000
000087E472590002BBA8BED908004500003C2B5D0000FF010A0BDEE7E447DEE7E441080030C51C454ADB00000000561225B400000000000A11775A

test.pcap
D4C3B2A1 0200 0400 00000000 00000000 FFFF0000 01000000
A27E03566B660200 C2000000 C2000000
000AE4842A9F000423DF7B9C0800451000B4979040004006D276C0A82778C0A827640016D4EB3C5714AF5DDBCF0A8018005AD0D300000101080A9E9AC3E8B665BF56EC9B0C50E96A3A1FB9850DE58054786D20B61FB729D0F122FFDB17E2147E51F03BD463C175110EF64291E71F9831091184351040EB8742F8D1CE4DDF5C3D7B6977FFE2C09225B2A2DD9234A956D021F8B36B05FF472C778AE989B934A09453AD1DC137F355BD2562FCD1A53BD887B12D7034B4D629060335D18728A393EE9DD8

test1-5.pcap
D4C3B2A1020004000000000000000000FFFF000071000000

D16E1C56DE6B0C00E8000000E8000000 # 16*14 + 8 = 232 bytes
0004000100060024A568310400000800
451000D8C03B400040069D1B0A3264360A32641F0016DD8C2C85210A9D6F940B501801FEABAD0000F4E9D04665495BE9D594CABAFFCEA8EDBCE2ED2692D7CA6133BE43E5808F4622E1C221E0A95023E677269990260B79DBC47118E95FE07F0623C01FDE384AB66996F07D2A61DB84F29379E32076816C34FC0BB9041BA7D1991332ED06610BC6B3162C431757DB725FB30BC1BD65563FE80B1A6F8DB0D003D97340A1E136D5CA080E9B0F3FFE92E3188DEF876BB2AC427E3981AE0D923EAB3D52FFADCBE89A26629A7AA48FC6F0BC3FFAFA2E60DE89989D

D16E1C56D8700C003E0000003E000000 # 16*3 + 14 = 62 bytes
0000000100062CD444B4005D00000800
45000028449240008006D9840A32641F0A326436DD8C00169D6F940B2C8521BA50103F3936850000000000000000

D16E1C56D9700C004200000042000000 
000300010006A56831042CD4000044B4
005D080045000028449240008006D9840A32641F0A326436DD8C00169D6F940B2C8521BA50103F3936850000000000000000

D26E1C562A4602004200000042000000 # 16*4 + 2 = 66 bytes
00020001000600005E00012900008100
032A00040000E3000001503FD0039F0000000000010000000000000000000000000000000000000000000001800000000000

D26E1C565F4602004200000042000000 # 16*4 + 2 = 66 bytes
00020001000600005E00012900008100
032B00040000E3000001503FD0039F0000000000010000000000000000000000000000000000000000000001800000000000


16*3 + 14

16*15 + 15 = 255
255 * 8 = 2040


(defun test () 
  (let ((result nil)) 
    (progn
      (dotimes (x 5)
	(setf (last result) (list x)))
      (return result))))


send_pcmu_short.pcapng:

0A0D0D0A1C0000004D3C2B1A01000000FFFFFFFFFFFFFFFF1C000000
010000002000000071000000FFFF000009000100060000000000000020000000
06000000E400000000000000A9220500B87BF30FC4000000C4000000000400010006000423DF7B9C00000800451000B4C5E540004006A421C0A82778C0A827640016E10F52D3E7ECE5BA72658018005AD0D300000101080A2F0D38992F10B94EF20DFC9C8D6CD5F57F654EEFAD39662A73FD6B8F38F7CD212A50575E9E6BD7B56BA21EBDCC339D8059A6A3760556BAE0DDFE42824066765A905530FEF29FFD05FE51309B5AEF0DD9908A1893F5BE073E2687595192F6C79C663A38290A57EA46F022A923F0FA33DF28E2524C37DC7BF4EB1969DABC3A60F60172AC75DB7627FAE4000000
060000006400000000000000A92205000F7CF30F4400000044000000000000010006000AE4842A9F00000800451000342D98400040063CEFC0A82764C0A82778E10F0016E5BA726552D3E86C801001F5E00000000101080A2F10B95D2F0D389964000000
060000009400000000000000A92205008E171D107400000074000000000000010006000AE4842A9F0000080045100064897040004006E0E6C0A82764C0A82778877B001622302571A9901EBC801801F5A44200000101080A2F10C4042F062A46E927D5EAE68889BFFE9CD1945E1B5AA128D562CEC182FC8745D9D836F0AE6E8DA8E063C5A43D4DD8DFADB94D42C2C28194000000
060000006400000000000000A9220500A2171D104400000044000000000400010006000423DF7B9C000008004510003412A44000400657E3C0A82778C0A827640016877BA9901EBC223025A18010005AA92500000101080A2F0D433F2F10C40464000000060000009400000000000000A92205009C201D107400000074000000000400010006000423DF7B9C000008004510006412A54000400657B2C0A82778C0A827640016877BA9901EBC223025A18018005AD08300000101080A2F0D43422F10C404DFCC27742A3D4B77E40C075CABE0772C8DF1FAE8ACF6B5EC5FE9AF75414B3B6C9EB480675C7BA353F4E85ECB7D51791794000000060000006400000000000000A9220500E8201D104400000044000000000000010006000AE4842A9F0000080045100034897140004006E115C0A82764C0A82778877B0016223025A1A9901EEC801001F5A75400000101080A2F10C4072F0D434264000000060000009400000000000000A92205002D1C31107400000074000000000000010006000AE4842A9F0000080045100064897240004006E0E4C0A82764C0A82778877B0016223025A1A9901EEC801801F5D6E800000101080A2F10C9252F0D43427312AD055AA2A8E5F68B949584DAFB00DFA1CDD3D11B3F07FE55A6E8EA57556357CAF20F2410632316E9C713C8FD81DD94000000060000009400000000000000A9220500B52131107400000074000000000400010006000423DF7B9C000008004510006412A64000400657B1C0A82778C0A827640016877BA9901EEC223025D18018005AD08300000101080A2F0D48612F10C925248C07AADA98674693C2DA256E37A82711175DEDB23D51C43C85637C79383DA083AB876F7DB330C4ADC6F0B0FA33BE5494000000060000006400000000000000A9220500052231104400000044000000000000010006000AE4842A9F0000080045100034897340004006E113C0A82764C0A82778877B0016223025D1A9901F1C801001F59CB600000101080A2F10C9262F0D48616400000006000000E400000000000000A922050038593110C4000000C4000000000400010006000423DF7B9C00000800451000B412A7400040065760C0A82778C0A827640016877BA9901F1C223025D18018005AD0D300000101080A2F0D486F2F10C926349CEE6BE51A28D80E9E7C1A2D0B7104378D123E6837EDF17869D04E46B4E9E30A66E8AC2FDB8D0098B15D147DEA996EBEDA9B3FCAC75F7E7812F50A52013CD9A715441E70FDFFE892314F662370783791077D2BE3092846B11947F3CEB0CC2C506E7F9754C8E14D041D10B42B7CF4A93DF95CFBDEE52957CE02207096C9C9ACE4000000060000006400000000000000A92205009B5931104400000044000000000000010006000AE4842A9F0000080045100034897440004006E112C0A82764C0A82778877B0016223025D1A9901F9C801001F59C1A00000101080A2F10C9342F0D486F6400000006000000E400000000000000A9220500C75C3110C4000000C4000000000400010006000423DF7B9C00000800451000B412A840004006575FC0A82778C0A827640016877BA9901F9C223025D18018005AD0D300000101080A2F0D48702F10C934226B15D3AC2BE1CFE94099A5732D10013058CA6C2B9B9CFD02D4C03B1F5FAF2A3A7411D6FD87244DECAC2608B72162D2D274097042D0D5FBCBF011F9983FB31F52425EFDC24BCDE65A823CA4DB43FCC8BE5BC08CAF3E322D48911AA1EA76A891FBA05D8EC770511F75D7889BE50EDA8DEB70385C0141F4BD309956D034FA53E6E4000000060000006400000000000000A92205001C5D31104400000044000000000000010006000AE4842A9F0000080045100034897540004006E111C0A82764C0A82778877B0016223025D1A990201C801001F59B9800000101080A2F10C9352F0D48706400000006000000E400000000000000A9220500B0603110C4000000C4000000000400010006000423DF7B9C00000800451000B412A940004006575EC0A82778C0A827640016877BA990201C223025D18018005AD0D300000101080A2F0D48712F10C9357854535B40F4F2C18CF24427D4A13247E0C931D71FB514299C0870BCA53B4A09C9C78E4D000D92B09398D1BCEA157BF408EF025EE7055452DAF54AE3A921D895FEA4CCBACC7ED507C71340DB73238691FF2E710849F24CDBF251E86D6FD6240BD64ADDAF22AF89EE364CA0C0EBEB527830BA009975166757B9713BB339FE1E65E4000000060000006400000000000000A9220500346131104400000044000000000000010006000AE4842A9F0000080045100034897640004006E110C0A82764C0A82778877B0016223025D1A990209C801001F59B1600000101080A2F10C9362F0D487164000000060000004C00000000000000A9220500987731102C0000002C000000000400010006000AE483C6CE000008060001080006040001000AE483C6CEDEE7E43A000000000000DEE7E40B4C000000060000005000000000000000A9220500A27731103000000030000000000400010006000AE483C6CE00008100026208060001080006040001000AE483C6CEDEE7E43A000000000000DEE7E40B50000000060000000C06000000000000A922050004783110EC050000EC050000000400010006000423DF7B9C00000800451005DC12AA400040065235C0A82778C0A827640016877BA990209C223025D18010005AD5FB00000101080A2F0D48772F10C936E3D0343B65C59E200FF920661054AFB208DA500B4711C0A40F5E488E1751E3C81AB1ECC34640BA79545B25F9663459AE39D18CF74647A3D5509ADB84AE5B66B229B23A22FD1944BDA759E7D3C7F659E99D85D678F9545F22F121768C3C8CD1ADFE6B138B6E9882865C9FCEF0AE30D34AE0D5C087E17B541595CE0086611E40B77BD06F5A257342238F0064DFE5BA04EF8007C4199A25AC2E83AAAD5FEE971BB7FFA537EDE82815033DF5DC50715E4F04F6741203FF0110FEC6BFF357AE23C14EBC4AAA9E941343F8289FD3917EFDE6FD5243CDDF70B8459C0FD08C82DF16D2C5390EC278874686577021214BE98BD07854796DA8EE94A7F7262737929ACF5642B76EADA788F1AA9865A63ECEABF003889DC7FAF308B01F8D0ACDE5BDF26B1DA42B0ABBDD3818AACA1A5BF638D3D77EF1038BF9A39DC734849422EA98348E594481A48BD0F33B5714BD7F79D1FA8EF949C8910CE45932CEE434882B8D69C6F480A7BCD38E59F716A8DB55E86E4FA5F3BDFFD9AD7B6D46BA5DA99C7242CCC2BEA9D1A106F56E90F35992C6529ECD2357FDD8FBC0E4B930937454330A3E8C2B119AD804E7D2C0387CD361CFA3214605D2F0882DE3C3189D7682840FE311995911803D371660E4F960B948689DABA865C82581601B97B7B58BF354114A8B68579A2DA1D6FE5EBF36CB122B234180B3A786A1ABBDCF5863A50F7DC551E13DAA9D6510935768009B9EB38686E93911D4C137AF797E017B4A03888EA3CE05B36D63792350FFDEEB78B4F4BAB503445CECA81B9DD70F30B980DB880F731FA57BE12D837E93AEA7E3E0033EBBEAE44E554A5C37D6D9A6CD11BF4B4505719F8CF58892226D97DF11DA7B6B5C53DC58757F03B7975975300634722E0454AC46149E2DD0A9FA381934E0264A1E57E0359C7C1B9DE40F021265C5C9E31B7EB6878BE59FFF28419D0022995836E7D9B73665E9ACE81C350E9B0E5E2F67D9D873EC7D7E5C335EA1AC40C08889478929E19B64774BB3DEDEA1BA692493AC543F31F16EACABBF50E8F90D4CCBBA9C9FB562488435F33635537176D985223A4E0D9E1B2B0D3240235F06773D3CD7CF37166688C9E96C16277E989E40AB5EBD45407C006DAAED5A7DB18E55816E85C256E320B61E8751FF16149F78CF682E95732C6C4484E5FB7100F137556BBC9D6B949EFFBA5E41D2434159612A0A41CF163E3D8644D81A23EC5DFC92D8053E96CF0B4C7F38EDE8EABE55F8B5E046EB22AF3EBAF7A284843AC7B24347D8EDA4E9CA14402A11B06CEECA82E2D988C90962FE2EC573AFAE081CF8FBA95E1F7008F93D83DDE1A60DDCAC3429E8AAA6166863591AEC6398E71F9461759325F411FB1F020CAB5C2F1B92FADBEBEF173C1FE43D9C6B1DABC8957A49E5935D2C6597D31BEE4C3403802F474209153EB3FA96907AC8A847C7EC2DF38A4CDE6F5FA1F0BC60F93EB9E516E6B8E2A5E1DEC298505D13C0C88881ACC5F1A24642BC2C7701C52D19CF33B835A2C10521DF009BEA14DB62C8D4040D4067F158D2B51D103ED4B0EFE4C3F5F214B1506A7710B8ABF6BE35AC74D1409713879596A8B88339F6CFC80A58285F8FE3155146F902E2066666ACD96B7B71B24261DAE068CA182E851B99CEABEB0B51D9417B987D595785150D38C75B453F2D38DDDB84BCDD203EB43FA6836E71F28D7904A8684EB1D42E0C539506451F188E0D707330B7EDF63CDEEEFAA10889B9922E920DFD2A1D4A0A76D77C715DE5B5F3490A64434C8383D673A61B8D33776FDC3D65ABA63C510ECEFB60FAC4C9DA50FE8361B4F9EC8CA9D04D5B2468F62DD119DF8E1593335D9B80C20A08C933CDF1D05CEE440933D08EDFDAB8CF0F9F0BC9C9ACA29D0BD82BAEAAF0C7270002F5C9A156448EB4141055457BAE6136C3DC91345C2F01C9F6D853B29064CC5762F513F8A06528DD0B02487DECEE26649F5D82FA4FEBC1E4DF7142CEA7EDC78DD24C6C31A7A6F353FC90FBAE5985AB89C28E500C761669E6E3A044236853621B775F0BD1C34767BA041110BC682162B969DC300C060000060000003C03000000000000A92205000E7831101C0300001C030000000400010006000423DF7B9C000008004510030C12AB400040065504C0A82778C0A827640016877BA9902644223025D18018005AD32B00000101080A2F0D48772F10C9361B8E663068BD04DF751FF45A3B21F758EC21AC3080E218E4C856358A2CB8E7CC7A726033B326B487BD7C2885C3EDB89C27607C93800886B2DE5E0F534EE27C2E68EFD675E0F1920934A458811B500BB4201CCA41148B3F948267CF19E57C895E5250BA05B4C8A860AEC5359B94309DE5291D8CB630013DFE321C23AEA4737F8810BF4692E23E43A5807CA59D418A6AB90A797E8BA327F5878BCD57837260DA3699559DDBA524892BFE96DA8BDC9B321A7758054B5B435FA511D40A1FC937EBB0B22903CE156912EF20D441C716F5C50F58FA2E91466789EC15EEB3A9EF55CE60410D1A8BF8D02AE3E2ED110C2711EBBAFFB9F9A14E1E87321B8A7C3E60F55CD61A93AFA934AE1CDF6501772F8246B1C9CA88636CA3C96A4E745C524F5A661337ED6A92BA97CF3C618F0CFF47732E463CF25127F0F92B6768E4DB3D2E52A52277EA78A7B7018BE4FE395E470F2CC6531458F5DFD0FEFA2F6A7674586C42F22121F913802CC2978C46A9D67F69547DE09360E2A06B6B0D8DFCA5B35F83B410D6625B45D87E6928D1760ECA39AF9DD020F5AE1DC38974F4BD5F98C8E9F91623DA8FE3254841FD753C388FE3723B83E021BCCDB3AED09D7BAE67F1E5D7E17F6CA38B6B8D7EF550B8B0F285CBED0A7EC023CA624E01C2CED70980989C5A75381BB60A57A328E3DB32645764129BC5A628E6F1C72A781C99210FD8C48D5F985194C71D80BB5BCCB1B3F5B2FBFC0175258C4C72C136033C039B4E7B56B1D8CC3F13B214DD03D48F699DB0C8131F5002F8546091194A0258F4950EC0C0E1284332C78BE4A19D7569296C8DDBE1B64C36FF219668C1CE8931D2A466A24ED396455E2C3F2B5A746522CBAF60BA897FD96D28A613A24F02696568732EBC1687456D811FC6A8BB33CA1076E384B7E211FA19B951581EA8FC006B4498D346F8EEE0F63F333FD92645BBDB377014A97326C320439C33B66489739314FA91F7733B0D5A7ECCC32F7AEF44FE27EDF4363AA8A6E42EF5198E505ED253C85DCEC73C030000060000006400000000000000A9220500607831104200000042000000000000010006005056A5A9F200008100026208060001080006040002005056A5A9F2DEE7E40B000AE483C6CEDEE7E43A000000000000000000000000000000000000000064000000


(lambda ()
  (cl-ppcre:regex-replace
   "cpc=[a-zA-Z]*"
   "sip:<adsbn;cpc=test;asdf>"
   '("<font color=\"red\">" :match "</fond>")))


52494646 RIFF
B2380100 file byte
57415645 WAVE
666D7420 fmt 
12000000 format info
07000100401F0000401F0000010008000000
66616374 fact
04000000 fact chunch byte number
80380100 sample number
64617461 data                     
80380100 

52494646 RIFF
B2A90300 file byte
57415645 WAVE
666D7420 fmt 
12000000 format info
07000100401F0000401F0000010008000000
66616374 fact
04000000 fact chunch byte number
80A90300 sample total length
64617461 data                     
80A90300 sample total length

7175F13F333C3A34353856BAB4B8BF6645373A4359D0C3C956464EC8C8D6F0CDDC45C9E2515A3C3F7DCBC9C0D25B422F333D453E30313FD8BEC7D1CECE7D4052BBB3C3595AAEABF4393EC8DBCFB7BADE33325DB5BD6D63DEBE492F3C57643B2E43C8CE4C42CFBB5C282DDEABABE3455BBF6E4B42E4CA3CDCB6BC63404CB2A4B9BBBFC3CA3FCFB2BE473646B9AABBC4CB72CB412E394CED53403BC7BDCDDE56ED
383DDF4C353D64EECA5963BCBEDF3F394EDB5D3F3E6EBDB6B9CBDFBBC741495DB8B9D649EEACADBE3B7DDEF1AEB1BE723F4EB3B1D3C8C6BBCA3946C4C5624B6EAEA7BADEE3ADA9F83946C7BBD83DDDAEC9D85DC4BE45E6B8BC4C4B6DB8ACDAC7ACB1EC2929CEB5593548BFA8B26ACCBAB5F83B48D1C952E5CAB1ADBE68544634CDBF4028294DBECF3B4DBBAFC73531E7CC5F423C5EC7CF6FEAD3B8BD3D3A42C1
B9673936B8B2EE36394058B5F637323CE9B8BA70BCC1E6E83C58BAC64C3D57ACA4AEC8D9B6AEEF3269BBBACD4C74B2B4DCD7BBBE48ECC05F343758BEB84AFBACABD0282752DD2D2031CBADBE49E7BAC947333DBBCA3B3349C8AFB751CAC06861B4B53F3B3C54E7494FC6AFD13F2F2E3D4139354BD8BFCD6EF3BF

52494646
7ADD0000
57415645
666D7420
12000000
07000100401F0000401F0000010008000000
66616374
04000000
40DD0000
64617461
40DD0000
