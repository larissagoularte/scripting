#!/bin/bash

menuPrincipal(){
	opcaoPrincipal=$(dialog              	 \
		--stdout                         \
		--title 'Menu Principal'         \
		--menu 'Escoha uma opção: '      \
		0 0 0                            \
		1 'Compra'                       \
		2 'Venda'                        \
		3 'Visualizar dados' 	  	 \
		4 'Alterar dados'                \
		5 'Gestão de base de dados'      \
		6 'Relatórios'  	         \
		0 'Sair do programa')

	case $opcaoPrincipal in
		0) sair ;;
		1) compra ;;
		2) venda ;;
		3) visualizar ;;
		4) alteraDados ;;
		5) gestaoBaseDados ;;
		6) relatorios ;;
	esac
}


#Compra
function compra() {
	#fazer aqui um if para  a verificação
	titulo=$(dialog --stdout --title "Compra de música" --nocancel --inputbox 'Título' 0 0)
	grupo=$(dialog --stdout --title "Compra de música" --nocancel --inputbox 'Grupo/Artista' 0 0)
	estilo=$(dialog --stdout --title "Compra de música" --nocancel --inputbox 'Estilo' 0 0)
	preco=$(dialog --stdout --title "Compra de música" --nocancel --inputbox 'Preço' 0 0)
	dataCp=$(dialog --stdout --title "Compra de música" --nocancel --inputbox 'Data de Compra:' 0 0)
	formato=$(dialog --stdout --title "Compra de música" --nocancel --inputbox 'Formato' 0 0)
	
	if [[ $titulo && $grupo && $estilo && $formato && $preco && $dataCp ]]; then
		echo "$titulo:$grupo:$estilo:$formato:$preco:$dataCp" >> basedados.txt
		echo "$titulo:$formato" >> formatos.txt
		dialog --stdout --title "Compra de música" --nocancel --msgbox "Compra efetuada com sucesso! A música "$titulo" do grupo/artista "$grupo" foi adicionada ao stock." 0 0 
		menuPrincipal

	else
		dialog --stdout --title "Aviso" --nocancel --msgbox "É necessário o preenchimento de todos os campos para a adicionar uma compra!" 0 0
		dialog --yesno 'Deseja tentar novamente?' 0 0
		if [ $? = 0 ]; then
		    compra
		else
			menuPrincipal
		fi
	fi	
}


#Venda
function venda(){

	bdVendas=bdVendas.txt
	basedados=basedados.txt
	show=$(cat basedados.txt)
	dialog --title "Venda de música"  --msgbox "$show" 0 0
	mVenda=$(dialog --stdout --title "Venda de música" --nocancel --inputbox 'Introuza o título da música a vender:' 0 0)
	pVenda=$(dialog --stdout --title "Venda de música" --nocancel --inputbox 'Introuza o preco de venda:' 0 0)
	dVenda=$(dialog --stdout --title "Venda de música" --nocancel --inputbox 'Introduza a data de venda: ' 0 0)
	
	if [[ $mVenda && $pVenda && $dVenda ]]; then
		var=$(grep $mVenda $basedados)
		echo "$var:$pVenda:$dVenda" >> $bdVendas
		grep -v $mVenda $basedados > tmp.txt
		rm $basedados
		mv tmp.txt $basedados
		dialog --title "Venda de música" --msgbox 'Venda efetuada com sucesso!' 0 0
		dialog --yesno 'Quer efetuar outra venda?' 0 0
	else
		dialog --stdout --title "Aviso" --nocancel --msgbox "É necessário o preenchimento de todos os campos para a adicionar uma compra!" 0 0
		dialog --yesno 'Deseja continuar?' 0 0
		if [ $? = 0 ]; then
		    venda
		else
			menuPrincipal
		fi

	fi
	menuPrincipal
}


function alteraDados(){
	opcaoAlterar=$(dialog                                   \
				   --stdout                                 \
				   --title 'Alteração de dados'             \
				   --nocancel 								\
				   --menu 'Escolha o que quer alterar: '    \
				   0 0 0                                    \
				   1 'Título'                               \
				   2 'Grupo/Artista'                        \
				   3 'Estilo'                               \
				   4 'Formato'                              \
				   5 'Preço'                                \
				   0 'Sair para o menu Principal')

	case $opcaoAlterar in
		0) menuPrincipal ;;
		1) alterarTitulo ;;
		2) alterarGrupo ;;
		3) alterarEstilo ;;
		4) alterarFormato ;;
		5) alterarPreco ;;
	esac
}

function alterarTitulo(){
	#é necessário fazer a verificação
	basedados=basedados.txt
	formatos=formatos.txt

	pedeTitulo=$(dialog --stdout --title 'Alteração de dados' --nocancel --inputbox 'Introduza o título que quer alterar: ' 0 0)
	alteraTitulo=$(dialog --stdout --title 'Alteração de dados' --nocancel --inputbox 'Para que título quer alterar: ' 0 0)
	if [[ $pedeTitulo && $alteraTitulo ]]; then
		grupo=$(grep $pedeTitulo $basedados | cut -f 2 -d ':')
		estilo=$(grep $pedeTitulo $basedados | cut -f 3 -d ':')
		formato=$(grep $pedeTitulo $basedados | cut -f 4 -d ':')
		preco=$(grep $pedeTitulo $basedados | cut -f 5 -d ':')

		grep -v $pedeTitulo $basedados > tmp.txt
		echo "$alteraTitulo:$grupo:$estilo:$formato:$preco" >> tmp.txt
		sed -i "s/$pedeTitulo/$alteraTitulo/" $formatos

		rm $basedados
		mv tmp.txt $basedados

		dialog --title "Modificação de título" --msgbox 'Título alterado para '$alteraTitulo' com sucesso!' 0 0 
	else
		dialog --stdout --title "Aviso" --nocancel --msgbox "É necessário o preenchimento de todos os campos para a alteração do título!" 0 0
		dialog --yesno 'Deseja continuar?' 0 0
		if [ $? = 0 ]; then
		    alterarTitulo
		else
			alteraDados
		fi
	fi


	menuPrincipal
}

function alterarGrupo(){
	#é necessário fazer a verificação
	basedados=basedados.txt

	pedeGrupo=$(dialog --stdout --title 'Alteração de dados' --nocancel --inputbox 'Introduza o título da música do grupo/artista que quer alterar: ' 0 0)
	alteraGrupo=$(dialog --stdout --title 'Alteração de dados' --nocancel --inputbox 'Para que grupo/artista quer alterar?: ' 0 0)
	if [[ $pedeGrupo && $alteraGrupo ]]; then
		titulo=$(grep $pedeGrupo $basedados | cut -f 1 -d ':')
		estilo=$(grep $pedeGrupo $basedados | cut -f 3 -d ':')
		formato=$(grep $pedeGrupo $basedados | cut -f 4 -d ':')
		preco=$(grep $pedeGrupo $basedados | cut -f 5 -d ':')

		grep -v $pedeGrupo $basedados > tmp.txt
		echo "$titulo:$alteraGrupo:$estilo:$formato:$preco" >> tmp.txt

		rm $basedados
		mv tmp.txt $basedados

		dialog --title "Modificação de grupo" --msgbox 'Grupo alterado para '$alteraGrupo' com sucesso!' 0 0 
	else
		dialog --stdout --title "Aviso" --nocancel --msgbox "É necessário o preenchimento de todos os campos para a alteração do grupo!" 0 0
		dialog --yesno 'Deseja continuar?' 0 0
		if [ $? = 0 ]; then
		    alterarGrupo
		else
			alteraDados
		fi
	fi
	

	menuPrincipal
}

function alterarEstilo(){
	#é necessário fazer a verificação
	basedados=basedados.txt

	pedeEstilo=$(dialog --stdout --title 'Alteração de dados' --nocancel --inputbox 'Introduza o título do estilo que quer alterar: ' 0 0)
	alteraEstilo=$(dialog --stdout --title 'Alteração de dados' --nocancel --inputbox 'Para que estilo quer alterar?: ' 0 0)
	if [[ $pedeEstilo && $alteraEstilo ]]; then
		titulo=$(grep $pedeEstilo $basedados | cut -f 1 -d ':')
		grupo=$(grep $pedeEstilo $basedados | cut -f 2 -d ':')
		formato=$(grep $pedeEstilo $basedados | cut -f 4 -d ':')
		preco=$(grep $pedeEstilo $basedados | cut -f 5 -d ':')

		grep -v $pedeEstilo $basedados > tmp.txt
		echo "$titulo:$grupo:$alteraEstilo:$ano:$preco" >> tmp.txt

		rm $basedados
		mv tmp.txt $basedados

		dialog --title "Modificação de estilo" --msgbox 'Estilo alterado para '$alteraEstilo' com sucesso!' 0 0 
		else
			dialog --stdout --title "Aviso" --nocancel --msgbox "É necessário o preenchimento de todos os campos para a alteração do estilo!" 0 0
			dialog --yesno 'Deseja continuar?' 0 0
			if [ $? = 0 ]; then
			    alterarEstilo
			else
				alteraDados
			fi
	fi
	
	menuPrincipal

}


function alterarFormato(){
	#é necessário fazer a verificação
	formatos=formatos.txt

	pedeFormato=$(dialog --stdout --nocancel --title 'Alteração de dados' --inputbox 'Introduza o título do formato que quer alterar: ' 0 0)
	alteraFormato=$(dialog --stdout --nocancel --title 'Alteração de dados' --inputbox 'Para que formato quer alterar?: ' 0 0)
	
	if [[ $pedeFormato && $alteraFormato ]]; then
		titulo=$(grep $pedeFormato $formatos | cut -f 1 -d ':')
		grupo=$(grep $pedeFormato $formatos | cut -f 2 -d ':')

		grep -v $pedeFormato $formatos > tmp.txt
		echo "$titulo:$alteraFormato" >> tmp.txt

		rm $formatos
		mv tmp.txt $formatos

		dialog --title "Modificação de formato" --msgbox 'Formato alterado para '$alteraFormato' com sucesso!' 0 0 
		else
			dialog --stdout --title "Aviso" --nocancel --msgbox "É necessário o preenchimento de todos os campos para a alteração do formato!" 0 0
			dialog --yesno 'Deseja continuar?' 0 0
			if [ $? = 0 ]; then
			    alterarFormato
			else
				alteraDados
			fi
	fi
	
	menuPrincipal

}

function alterarPreco(){
	
	basedados=basedados.txt

	pedePreco=$(dialog --stdout --title 'Alteração de dados' --nocancel --inputbox 'Introduza o titulo do preço que quer alterar: ' 0 0)
	alteraPreco=$(dialog --stdout --title 'Alteração de dados' --nocancel --inputbox 'Para que preço quer alterar?: ' 0 0)
	
	if [[ condition ]]; then
		titulo=$(grep $pedePreco $basedados | cut -f 1 -d ':')
		grupo=$(grep $pedePreco $basedados | cut -f 2 -d ':')
		estilo=$(grep $pedePreco $basedados | cut -f 3 -d ':')
		formato=$(grep $pedePreco $basedados | cut -f 4 -d ':')

		grep -v $pedePreco $basedados > tmp.txt
		echo "$titulo:$grupo:$estilo:$formato:$alteraPreco" >> tmp.txt

		rm $basedados
		mv tmp.txt $basedados

		dialog --title "Modificação de preço" --msgbox 'Preço alterado para '$alteraPreco' com sucesso!' 0 0 
		else
			dialog --stdout --title "Aviso" --nocancel --msgbox "É necessário o preenchimento de todos os campos para a alteração do preço!" 0 0
			dialog --yesno 'Deseja continuar?' 0 0
			if [ $? = 0 ]; then
			    alterarPreco
			else
				alteraDados
			fi
	fi
	
	menuPrincipal

}
#esta função permite visualizar ordenando por categoria
function visualizar(){
	opcaoVisualizar=$(dialog             \
		--stdout                         \
		--title 'Visualizar'         	 \
		--nocancel						 \
		--menu 'Escoha uma opção: '      \
		0 0 0                            \
		1 'Titulo'                       \
		2 'Grupo'                        \
		3 'Estilo'                       \
		4 'Formato'                      \
		0 'Sair para o menu Principal')

	

	case $opcaoVisualizar in
		
		0) menuPrincipal ;;
		#ordenar por titulo
		1) visualizarTitulo;;
		#ordenar por grupo
		2)  visualizarGrupo;;
		#ordenar por estilo
		3) visualizarEstilo;;
		#ordenar por formato
		4) visualizarFormatos;;
		
		
	esac
	
}
#funções pertencentes a visualizar()
function visualizarTitulo(){
	exw=$(sort -n -t ":" -k 1 basedados.txt)
	dialog --title "Organizado por Títulos" --msgbox "$exw" 0 0
	visualizar
}
function visualizarGrupo(){
	exm=$(sort -t ":" -k 2 basedados.txt)
	dialog --title "Organizado por Grupos" --msgbox "$exm" 0 0 
	visualizar
}
function visualizarEstilo(){
	exmo=$(sort -t ":" -k 3 basedados.txt)
	dialog --title "Organizado por Estilo" --msgbox "$exmo" 0 0 
	visualizar
}

function visualizarFormatos() {

    # É necessário organizar o ficheiro dos formatos primeiro, caso contrário não ficam ordenados por formato
    sort -f -k 2 -t ':' -o formatos.txt formatos.txt
    
    titulos=($(awk -F ':' '{ awkArray[counter++] = $2; } END { for (n=0; n<counter;n++) print awkArray[n]; }' formatos.txt)) 

    for titulo in "${titulos[@]}"
    do
        if grep -q $titulo basedados.txt; then

			# Vai buscar a restante informação da música
            line2=$(grep $titulo basedados.txt)
            # Concatena toda a informação referente a música

        fi
		dialog --title "Formatos" --msgbox "$line2" 0 0  
    done  
	visualizar


}

#função para mostrar relatorios
function relatorios(){
	opcaoRelatorios=$(dialog             \
		--stdout                         \
		--nocancel						 \
		--title 'Relatórios'         	 \
		--menu 'Escoha uma opção: '      \
		0 0 0                            \
		1 'Listar Musicas Vendidos'      \
		2 'Listar Musicas em Stock'      \
		3 'Número de Musicas em Stock'   \
		4 'Calcular Lucros'              \
		0 'Sair para o menu Principal')

	case $opcaoRelatorios in
		0) menuPrincipal;;
		1) musicasVendidas;;
		2) musicasStock;;
		3) numStock;;
		4) lucroTotal;;
	esac
}

#Relatório de veículos em stock
function musicasVendidas(){
	vV=$(cat bdVendas.txt)
	dialog --title "Músicas vendidas" --msgbox "$vV" 0 0
	relatorios
}
function musicasStock(){
	vS=$(cat basedados.txt)
	dialog --title "Stock de músicas" --msgbox "$vS" 0 0
	relatorios
}

function numStock(){
	numeroMS=$(grep -c ^ basedados.txt)
	dialog --title "Relatório"  --msgbox "O número de MÚSICAS em stock é de: ""$numeroMS" 0 0
	relatorios
}

function lucroTotal(){

	vendas=$(cut -d : -f 5 bdVendas.txt)
	compra=$(cut -d : -f 7 bdVendas.txt)
	
	let somaVendas = 0;
	let somaCompras = 0;
	
	for i in $vendas; do let somaVendas+=$i; echo $i; done;
	for j in $compra; do let somaCompras+=$j; echo $j; done;
	
	let lucro=($somaCompras - $somaVendas)
	dialog --title "Lucro total" --msgbox "$lucro €" 0 0
	relatorios
}
function gestaoBaseDados(){
	opacaoBD=$(dialog             \
		--stdout                         \
		--title 'Gestão de Base de dados'\
		--nocancel						 \
		--menu 'Escoha uma opção: '      \
		0 0 0                            \
		1 'Backup-Criar uma cópia de segurança' \
		2 'Restaurar uma cópia de segurança'    \
		3 'Apagar uma cópia de segurança'       \
		0 'Sair para o menu Principal')
	case $opacaoBD in
		0) menuPrincipal ;;
		1) copia;;
		2) restauroCopia;;
		3) apagarCopia;;
	esac
}
#FUNCÕES DA FUNCÃO GESTAO BASE DE DADOS 
		function copia(){
			nf=$(date +"%m-%d-%H-%M")
			cs=$(cp basedados.txt Backups/$nf.txt)
			dialog --title "Backup" --msgbox "Copia de Segurança efetuada com sucesso!" 0 0 
			gestaoBaseDados
		}
		#esta função vai apagar copias de segurança
		function apagarCopia(){
			ls Backups/ > output_file.txt
			show=$(cat output_file.txt)
			dialog --title "Backup"  --msgbox "$show" 0 0
			nomeFich=$(dialog --stdout --nocancel --inputbox 'Introduza o nome do ficheiro a restaurar:' 0 0)
			if [[ $nomeFich ]]; then
				while [[ $nomeFich ]]; do
				dialog --yesno 'Tem a certeza que deseja apagar?' 0 0
					if [ $? = 0 ]; then
						apagarDefinitivo
					else
						dialog --title "Aviso" --msgbox 'Não foi apagado nenhuma Cópia de Segurança!' 0 0
						gestaoBaseDados
					fi
				done
			else 
				dialog --title "Aviso" --msgbox 'Não foi apagado nenhuma Cópia de Segurança!' 0 0
				gestaoBaseDados
			fi
		}
		#esta função pertence a apagarCopia()
		function apagarDefinitivo(){
				ac=$(rm Backups/$nomeFich)
				dialog --title "O Backup $nomeFich foi apagado! " --msgbox "$ac" 0 0
				dialog --yesno 'Deseja apagar outra Cópia de Segurança?' 0 0
				if [ $? = 0 ]; then
					apagarCopia
				else
					gestaoBaseDados
				fi
		}
		function restauroCopia(){
			ls Backups/ > output_file.txt
			show=$(cat output_file.txt)
			dialog --title "Backup"  --msgbox "$show" 0 0
			nomeFich=$(dialog --stdout --nocancel --inputbox 'Introduza o nome do ficheiro a restaurar:' 0 0)
			retaurarCopia=$(cp -f  Backups/$nomeFich basedados.txt)
			gestaoBaseDados
		}
menuPrincipal
