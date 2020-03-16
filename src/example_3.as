package
{
	//IMPORT LIBS
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.setInterval;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.clearInterval;
	import flashx.textLayout.formats.Float;
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	import fl.transitions.TweenEvent;
	import flash.ui.Keyboard;
	
	public class MovAngular extends MovieClip
	{		
		//ENGINE
		private var FPS:int = 41;
		private var tempo_ms:Number = 0;		
		private var tempo_seg:Number = 0;
		private var tempo_ms_disparo:Number = 0;
		private var intervalo:Number;	
		private var grafico:Grafico = new Grafico();
		private var ponto:Shape = new Shape();
		private var graph:Shape = new Shape();
		private var arrInfo:Array;
		private var informacoes:Array;
		private var popup:Popup = new Popup();
		
		//MECANICA
		private var gravidade = 9.8; //9.2 / 9.2
		
		//ATIVIDADE
		private var UP = false;
		private var DOWN = false;
		private var SPACE = false;
		private var tangente;
		private var angulo = 0;
		private var forca = 0;
		private var massa = 15; //15kg DE MASSA DEFINIDOS PARA A BALA DE CANHÃO
		private var atirar = false; //ESTE BOOLEAN CONTROLA A AÇÃO DURANTE O TIRO DO CANHÃO.
		private var preparar = false; //ESTE BOOLEAN CONTROLA A MUDANÇA DE ESTADO DA VARIAVEL BOOLEANA ATIRAR.
		private var aceleracaoInicial = 0;
	    private var aceleracaoTotal = 0;
		private var acerelacaoX = 0;
		private var acerelacaoY = 0;
		private var vX = 0; //VELOCIDADE X
		private var vY = 0; //VELOCIDADE Y
		private var velocidadeTotal = 0; //VELOCIDADE TOTAL | SOMA DOS VETORES DE VELOCIDADE X e Y
		private var porcentoX;
		private var porcentoY;
		private var X = 0; //PROXIMA CORDENADA DA BOLA NO EIXO DAS ABSCISSAS (X);
		private var Y = 0; //PRÓXIMA CORDENADA DA BOLA NO EIXO DAS ORDENADAS (Y)
		private var friccao:Number = 0.6;
		
		//OBJ
		private var bola:MOV_bola = null;
		private var resetGrafico:Boolean = true;
		
		public function MovAngular()
		{
			//arrInfo[contador] = null;
			
			menu.btn_graf.Unlock(); //BOTÃO DE GRÁFICO
			menu.btn_trace.Unlock(); //BOTÃO DE TRAÇOS
			menu.btn_eraseTrace.Unlock(); //BOTÃO DE LIMPAR TRAÇOS
			ponto.visible = false;
			
			//LISTENERS
			this.addEventListener("STOP", GLOBAL_stop);
			this.addEventListener("PLAY", GLOBAL_play);
			this.addEventListener("PAUSE", GLOBAL_pause);
			this.addEventListener("STEP_PLAY", GLOBAL_stepPlay);
			this.addEventListener("CONTROLE_GRAFICO" , GLOBAL_grafico);
			this.addEventListener("CONTROLE_TRACO", GLOBAL_controlTraco);
			this.addEventListener("CONTROLE_APAGAR-TRACO", GLOBAL_TraceErase);
			
			//TRATA OS CAMPOS DE TEXTO
			this.menu.opt.TXT_grav.text = gravidade.toString();
			this.menu.opt.TXT_massa.text = massa.toString();
			
			if( menu.btn_graf.getButtonState() == "Normal" || menu.btn_graf.getButtonState() == "Off" )
			{
				grafico.visible = false;
			}
			else if ( menu.btn_graf.getButtonState() == "Pressed" )
			{	
				grafico.visible = true;
			}
			
			grafico.x = 250;
			grafico.y = 35;
			addChild(grafico);
			
			popup.visible = false;
			addChild(popup);
			
			
			//DA PLAY NA ATIVIDADE
			this.dispatchEvent( new Event("PLAY") );
			
		}
		
		private function funcRecursiva()
		{
			//CALCULO DE ESTATISTICAS
			tempo_ms += FPS; //Tempo em Milissegundos.
			tempo_seg = Math.floor(tempo_ms / 1000); //Tempo em segundos.

			//CALCULO DO CANHÃO
			if ( !atirar ) //CASO SEJA FALSE PERMITE A MOVIMENTAÇÃO E O TIRO DO CANHÃO
			{
					//CONTROLES DO CANHÃO
					if ( UP )
					{
						if ( angulo < 90 )
						{
							mov_canhao.canhao.rotation--;
							angulo++; //CONTROLA O ANGULO DO CANHÃO
						}
					}
					if ( DOWN )
					{
						if ( angulo >= 0 )
						{
							mov_canhao.canhao.rotation++;
							angulo--; //CONTROLA O ANGULO DO CANHÃO
						}
					}
					
					if ( SPACE )
					{
						if ( forca < 500 )
						{
							upBar.barraForca.forceLine.width += 5; //INCREMENTA BARRA DE FORÇA | VARIA DE X ATÉ X
							forca += 10;
							preparar = true;
							this.menu.infor.TXT_forca.text = String (forca) + " N";
						}
							
					}
					else
					{
						upBar.barraForca.forceLine.width = 1; //RESETA BARRA DE FORÇA
						
						if ( preparar )
						{
							atirar = true;
							preparar = false;
						}
					}
					
					//ATUALIZA POSIÇÃO DA MIRA ; IMPORTANTE POIS SERVE COMO PONTO DE REFERENCIA PARA DISPARAR OS PROJÉTEIS.
					mov_canhao.mira.x = mov_canhao.canhao.x + Math.round(130 * Math.cos(angulo / 180 * Math.PI));
			        mov_canhao.mira.y = mov_canhao.canhao.y - Math.round(130 * Math.sin(angulo / 180 * Math.PI));
			}
			else //NESTE MOMENTO HÁ UM TIRO OCORRENDO
			{
				tempo_ms_disparo += FPS;
				
				if ( bola == null )
				{
					//REALIZA O TIRO DO CANHÃO
					bola = new MOV_bola();
					bola.x = mov_canhao.x + mov_canhao.mira.x;
					bola.y = mov_canhao.y + mov_canhao.mira.y;
					this.addChild(bola);
					
					//CALCULA A ACELERAÇÃO DO CORPO BASEANDO-SE NA FORMULA DA FORÇA | ACELERAÇÃO = MASSA / FORÇA
					aceleracaoInicial = forca / massa;
				
					//SETA VELOCIDADE INICIAL
					//DEFINE PROPORÇÃO DA FORÇA BASEADA NO ANGULO (REGRA DE TRÊS)
					//porcentoY = Math.round( (angulo / 90) * 100 );
					//porcentoX = 100 - porcentoY;										
					
					vX = ( (Math.cos(angulo / 180 * Math.PI) * aceleracaoInicial)); //EIXO X 
				    vY = ( (Math.sin(angulo / 180 * Math.PI) * aceleracaoInicial)); //EIXO Y
				}
				else
				{					
					X = bola.x;
					Y = bola.y;
					
					//PROCESSO DE MOVIMENTAÇÃO DA BOLA					
					vY -= (gravidade / 9.8);
				    X += vX;
					Y -= vY ;
					
					if ( Y > 470 )	//COLISÃO COM O TETO
					{
						vY *= -friccao;
						vX *= friccao;
						Y = 470;												
					}
					if ( Y < 35 )	//COLISÃO COM O PISO
					{
						vY *= -friccao;
						vX *= friccao;
						Y = 35;
					}
					
					if (X > 870) //COLISÃO DO LADO DIREITO;
					{
						X = 870;
						vX *= - friccao;
					}
					
					if (X < 250) //COLISÃO DO LADO ESQUERDO;
					{
						X = 250;
						vX *= - friccao;
					}
					
					aceleracaoTotal = vX + vY;					
					bola.rotation = 0;					
					
					//Rotaciona a seta da bola
					//var anguloRot:Number = Math.round(Math.atan((bola.y - Y ) / (X - bola.x)) / (Math.PI / 180 ));
					//
					//if( bola.x < X)
					//{
						//anguloRot += 180;
					//}
					//else if (X <= bola.x && Y < bola.y) 
					//{
						//anguloRot -= 180;					
					//}
					//
					//bola.seta.rotation = anguloRot;					
					//bola.seta.corpo.height = aceleracaoTotal;
					//bola.seta.ponta.y = bola.seta.corpo.height - 7;
					
					bola.x = X;
					bola.y = Y;
					
					//PLOTA O GRÁFICO DE VELOCIDADE POR TEMPO
					if (plotarGrafico(aceleracaoTotal, tempo_ms_disparo) != null) 
					{
						grafico.addChild(plotarGrafico(aceleracaoTotal, tempo_ms_disparo));
					}
					
					informacoes = new Array();
					informacoes.push(tempo_ms, aceleracaoTotal);
					arrInfo.push(informacoes);
					
					plotarTragetoria(arrInfo); //PLOTA A TRAGETÓRIA DA BALA
				}
				
			}
				
			//CHAMA A FUNÇÃO DE ATUALIZAÇÃO DE AMBIENTE
		    atualizaInfo();			
		}
		
		private function atualizaInfo()	//ATUALIZAR INFORMAÇÕES
		{
			this.menu.infor.TXT_ms.text = tempo_ms.toString() + " Ms";
			this.menu.infor.TXT_seg.text = tempo_seg.toString() + " Sec";
			this.menu.infor.TXT_pos.text = angulo.toString() + " º";
			
			if ( bola != null )
			{
				if (aceleracaoTotal > 0 && aceleracaoTotal < 1 )
				{
					this.menu.infor.TXT_aceleracao.text = "0 Px/r";
					
				}
				else
				{
					this.menu.infor.TXT_aceleracao.text = String (aceleracaoTotal.toFixed(2) ) + " Px/r";
				}
				
				this.menu.infor.TXT_forca.text = String (forca) + " N";
			}
		}
		
		private function limparInfo()
		{
			this.menu.infor.TXT_ms.text = "";
			this.menu.infor.TXT_seg.text = "";
			this.menu.infor.TXT_pos.text = "";
			this.menu.infor.TXT_aceleracao.text = "";
			this.menu.infor.TXT_forca.text = "";
		}
		
		function GLOBAL_stop( e:Event ) //REINICIA A RECURSÃO
		{
			trace("GLOBAL_STOP");

			//CONTROLES
			menu.control.btn_pause.Disable();
			menu.control.btn_stop.Disable();
			menu.control.btn_play.Enable();
			menu.opt.Unlock();
			
			//CONTROLES DO CANHAO
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, EVT_keyDown);
			stage.removeEventListener( KeyboardEvent.KEY_UP, EVT_keyUp);
			
			//RESETAR OBJETOS
			if ( bola != null)
			{
				this.removeChild(bola);
				bola = null;		
			}
			
			forca = 0;
			tempo_ms_disparo = 0;
			this.atirar = false;
			limparInfo();

			//reseta o gráfico
			var grafX = grafico.x;
			var grafY = grafico.y;
			var grafVisible = grafico.visible;
			 
			removeChild(grafico);
			grafico = new Grafico();
			grafico.x = grafX;
			grafico.y = grafY;
			grafico.visible = grafVisible;
			addChild(grafico);
			
			clearInterval( intervalo );
			
			tempo_ms = 0;
			tempo_ms_disparo = 0;
			tempo_seg = 0;
			GLOBAL_TraceErase(null);
		}
		
		function GLOBAL_play( e:Event ) //INICIA A RECURSÃO
		{
			trace("GLOBAL_PLAY");
			
			arrInfo = new Array();
			
			menu.control.btn_pause.Enable();
			menu.control.btn_stop.Enable();
			menu.control.btn_play.Disable();
			menu.opt.Lock(); //TRANCA O MENU DE OPÇÕES
			
			//SETA OS ATRIBUTOS DE ACORDO COM OS CAMPOS 
			gravidade = Number(menu.opt.TXT_grav.text); 
			massa = Number(menu.opt.TXT_massa.text);
			
			//CONTROLES
			stage.addEventListener( KeyboardEvent.KEY_DOWN, EVT_keyDown);
			stage.addEventListener( KeyboardEvent.KEY_UP, EVT_keyUp);
			
			// O método setInterval fará a recursividade da função funcRecursiva, definindo um atraso de 41ms entre suas iterações;
			// 41ms equivale a aproximadamente 24fps			
			//intervalo = setInterval( funcRecursiva, 41 );
			
			intervalo = setInterval( funcRecursiva, FPS ); //CRIA A FUNÇÃO RECURSIVA
			resetGrafico = true;
		}
		
		function GLOBAL_pause( e:Event ) //PAUSA A RECURSÃO
		{
			trace("GLOBAL_PAUSE");
				
				menu.control.btn_play.Enable();
				clearInterval( intervalo );
		}
		
		function GLOBAL_stepPlay( e:Event ) //EXECUTA A RECURSÃO PASSO A PASSO
		{
			trace("GLOBAL_STEPPLAY");

			menu.control.btn_pause.Disable();
			menu.control.btn_play.Enable();
			menu.control.btn_stop.Enable();
			clearInterval( intervalo );

			funcRecursiva();
		}
		
		function GLOBAL_grafico( e:Event ) //GRÁFICO
		{
			trace("GLOBAL_controlGrafico");
			if( menu.btn_graf.getButtonState() == "Pressed" )
			{
				grafico.visible = true;
			}
			else if( menu.btn_graf.getButtonState() == "Normal" )
			{
				grafico.visible = false;
			}
		}

		function GLOBAL_controlTraco( e:Event )	//Define a visibilidade do traçado
		{		
			if( menu.btn_trace.getButtonState() == "Pressed" )
			{
				ponto.visible = true;
				
				for (var i:int = 0; i < arrInfo.length; i++) 
				{
					if (arrInfo[i].length >= 3) 
					{
						arrInfo[i][2].visible = true;
					}				
				}		
			}
			else if( menu.btn_trace.getButtonState() == "Normal" )
			{
				ponto.visible = false;
				
				for (var k:int = 0; k < arrInfo.length; k++) 
				{
					if (arrInfo[k].length >= 3) 
					{
						arrInfo[k][2].visible = false;
					}				
				}	
			}
		}
		
		function GLOBAL_TraceErase( e:Event )	//Apaga o traçado
		{
			if (contains(ponto))
			{
				this.removeChild( ponto );
				ponto = new Shape();
			}
			
			for (var i:int = 0; i < arrInfo.length; i++) 
			{
				if (arrInfo[i].length >= 3) 
				{
					if (contains(arrInfo[i][2] as MovieClip)) 
					{
						arrInfo[i][2].removeEventListener(MouseEvent.CLICK, handlerMouse);
						removeChild(arrInfo[i][2] as MovieClip);
					}
				}	
			}
			popup.visible = false;			
		}	
		
		function plotarTragetoria(info:Array)	//PLOTAGEM DA TRAGETÓRIA
		{
			if (info.length % 9 == 0) 
			{
				var pontoInfo:MovieClip = new MovieClip;
				pontoInfo.graphics.beginFill(0x0033CC, 1);
				pontoInfo.graphics.drawCircle(bola.x, bola.y, 5);
				pontoInfo.graphics.endFill();
				
				info[info.length - 1].push(pontoInfo);
				addChild(info[info.length - 1][2]);
				
				pontoInfo.addEventListener(MouseEvent.CLICK, handlerMouse);
				pontoInfo.buttonMode = true;
				
				if( menu.btn_trace.getButtonState() == "Normal" )
					pontoInfo.visible = false;
			}
			else 
			{
				ponto.graphics.beginFill(0xCC0000, 1);
				ponto.graphics.drawCircle(bola.x, bola.y, 1);
				ponto.graphics.endFill();	//termina o preenchimento.
				this.addChild(ponto);
			}
		}
		
		function handlerMouse(e:MouseEvent):void //Controla 
		{
			popup.x = mouseX -50;
			popup.y = mouseY -60;
			popup.visible = true;
			
			loop: for (var i:int = 0; i < arrInfo.length; i++) 
			{
				if (arrInfo[i].length >= 3) 
				{	//Se a array de informações tiver um sprite (posição [2])
					if (e.target.name == arrInfo[i][2].name) 
					{	//Se o nome do sprite clicado coincidir com o armazenado no array, resgata as demais informações.
						popup.tempo.text = arrInfo[i][0];
						popup.acc.text =  String(arrInfo[i][1].toFixed(2));
						break loop;
					}					
				}				
			}			
		}
		
		function plotarGrafico(acc:Number, tempo):Shape	//PLOTAGEM DO GRÁFICO
		{	//Necessário correção.
			if (resetGrafico) 
			{
				graph.graphics.clear();
				graph.graphics.moveTo(36, 139);
				resetGrafico = false;
			}
			
			//if ((tempo/50) < 110) //Caso os valores não ultrapassem o limite do gráfico.
			//{				
				graph.graphics.lineStyle(1);
				graph.graphics.lineTo((tempo/50) + 36, acc*-1 + 139);
				graph.graphics.moveTo((tempo/50) + 36, acc*-1 + 139);
				//graph.graphics.moveTo((tempo / 30) + 36, acc*(-1) + 139);
				
				//ponto.graphics.beginFill(0xCC0000, 0.5);			//Inicia o preenchimento do ponto que será adicionado na tela.
				//ponto.graphics.drawCircle((tempo / 30) + 34, aceleracao * (sentido) + 137, 1);	//Define o x e y do ponto que será plotado; as coordenadas são baseadas no instante da velocidade.
																									//O tempo (ponto x) é dividido por 30 para caber no Movie Clip "grafico".
																									//A velocidade (ponto y) é multiplicada por (-1) para inverter o plano cartesiano.
																									//NOTA: AS CONSTANTES 34 e 137 corrigem o ponto de origem do MovieClip para que sejam plotados exatamente dentro do campo de análise.
															

				
				//ponto.graphics.endFill();			    //termina o preenchimento.
				return graph;							//retorna o ponto que será plotado.
			//}
			//else 
			//{
				//return null;
			//}
		}				
		
		function EVT_keyDown( e:KeyboardEvent ) //TRATA EVENTOS DE TECLADO
		{
			switch (e.keyCode)
			{
				case Keyboard.DOWN:
					DOWN = true;
					break;
					 
				case Keyboard.UP:
					UP = true;
					break;
					
				case Keyboard.SPACE:
					SPACE = true;
					break;
					
			}
		}
		
		function EVT_keyUp( e:KeyboardEvent ) //TRATA EVENTOS DE TECLADO
		{
			switch (e.keyCode)
			{
				case Keyboard.DOWN:
					DOWN = false;
					break;
					 
				case Keyboard.UP:
					UP = false;
					break;
					
				case Keyboard.SPACE:
					SPACE = false;
					break;
					
			}
		}
	}	
}