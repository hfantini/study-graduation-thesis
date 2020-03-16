package
{
	//IMPORT LIBS
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.setInterval;
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flashx.textLayout.formats.Float;

	public class Gravidade extends MovieClip
	{
		//VARIÁVEIS
		
			//ENGINE
			private var Estado:String = "stop";
			private var tempo_ms:Number = 0;		
			private var tempo_seg:Number = 0;
			private var grafico:Grafico = new Grafico();
		
			//MECÂNICA
			private var intervalo:Number;
			private var FPS:int = 41;
			private var iniX:Number;
			private var iniY:Number;
			
			//ATIVIDADE
			private var gravidade:Number = 9.8; //CONSTANTE DEFAULT 
			private var rotacao:Number = 1;
			private var Vx:Number = 0;
			private var Vy:Number = 0;
			private var Y:Number;
			private var X:Number;
			private const friccao:Number = 0.6;
			private var raio:Number;


		public function Gravidade()
		{
			
			//Define padrões da mecânica da atividade.
			menu.btn_graf.Unlock();
			desabilitar_bottons();

			//Define as variáveis com os valores iniciais da bola.
			X = bola.x;
			Y = bola.y;
			iniX = bola.x;
			iniY = bola.y;
			raio = bola.width / 2; // RAIO DA BOLA
			
			//Opção da gravidade localizada no painel.
			menu.opt.TXT_grav.text = String(gravidade);
			
			//LISTENERS
			this.addEventListener("STOP", GLOBAL_stop);
			this.addEventListener("PLAY", GLOBAL_play);
			this.addEventListener("PAUSE", GLOBAL_pause);
			this.addEventListener("STEP_PLAY", GLOBAL_stepPlay);
			this.addEventListener("CONTROLE_GRAFICO", GLOBAL_controlGrafico);
			
			// O método setInterval fará a recursividade da função funcRecursiva, definindo um atraso de 41ms entre suas iterações;
			// 41ms equivale a aproximadamente 24fps			
			//intervalo = setInterval( funcRecursiva, 41 );
			
			seta.visible = false;
			
			if( menu.btn_graf.getButtonState() == "Normal" || menu.btn_graf.getButtonState() == "Off" )
			{
				grafico.visible = false;
			}
			else if ( menu.btn_graf.getButtonState() == "Pressed" )
			{	
				grafico.visible = true;
			}
			
			grafico.x = 250;
			grafico.y = 10;
			addChild(grafico);
		}
		
		//FUNÇÃO RECURSIVA
		
		private function funcRecursiva() //FUNÇÃO PRINCIPAL DA ATIVIDADE
		{
			//CALCULO DE ESTATISTICAS
			tempo_ms += FPS;
			
			tempo_seg = Math.floor(tempo_ms / 1000);		//Tempo em segundos.
			
			//MOVIMENTACAO
			Vy += gravidade;
			Y += (Vy / 9.8);
			
			rotacao = (Vy / 9.8);
			if( rotacao < 0 )
			rotacao *= -1;
			
			//CONDICIONAIS
			
			/*
			 * Se a bola atingir o limite do palco, inverte-se seu sentido ( * (-1) )
			 * */
			if( Y >= 490 - raio )
			{
				Y = 490 - raio;
				Vy *= -friccao;				
				rotacao = 0;
				
			}
									
			//APLICA A GRAVIDADE E A ROTAÇÃO
			bola.y = Y;
			bola.rotation += rotacao;
			
			atualizaInfo(); // ATUALIZA INFO
		}
		
		function atualizaInfo()
		{
			menu.infor.TXT_ms.text = tempo_ms.toString() + " ms";
			menu.infor.TXT_seg.text = tempo_seg.toString() + " seg";
			
			var velo_atual = Vy / 9.8
			
			//trace(velo_atual);
			
			if( velo_atual.toFixed(0) >= 0 && velo_atual.toFixed(0) < 1 )
			{
				menu.infor.TXT_velo.text = " 0 p/R ";
			}
			else
			{
				menu.infor.TXT_velo.text = String( velo_atual.toFixed(2) ) + " p/R";
			}
			
			//menu.infor.TXT_rotate.text = bola.rotation.toFixed(0) + " Graus/R";
			if (velo_atual > 0) 
			{
				seta.rotationX = 0;
				seta.y = bola.y;
				seta.corpo.height = velo_atual;
				seta.ponta.y = seta.corpo.height - 4.2;
			}
			if (velo_atual < 0) 
			{
				seta.rotationX = 180;
				seta.y = bola.y;
				seta.corpo.height = velo_atual *-1;
				seta.ponta.y = seta.corpo.height - 4.2;
			}	
			
			if (plotarGrafico(velo_atual) != null) 
			{
				grafico.addChild(plotarGrafico(velo_atual));
			}

		}
		
		function clearInfo()
		{
			menu.infor.TXT_ms.text = "";
			menu.infor.TXT_seg.text = "";
			menu.infor.TXT_rotate.text = "";
			menu.infor.TXT_velo.text = "";
		}
		
		//EVENTOS
		
		function GLOBAL_stop( e:Event ) //REINICIA A RECURSÃO
		{
			trace("GLOBAL_STOP");
			

			menu.control.btn_pause.Disable();
			menu.control.btn_stop.Disable();
			trace("disable");
			menu.control.btn_play.Enable();
			Estado = "stop";
			clearInterval( intervalo );
			
			clearInfo();
			bola.rotation = 0;
			bola.x = iniX;
			bola.y = iniY;
			Y = iniY;
			X = iniX;
			Vx = 0;
			Vy = 0;
			menu.opt.Unlock();
			
			tempo_ms = 0;
			tempo_seg = 0;
			seta.visible = false;
			
			/*
			 * Instancia um novo gráfico.
			 */
			
			var grafX = grafico.x;
			var grafY = grafico.y;
			var grafVisible = grafico.visible;
			 
			removeChild(grafico);
			grafico = new Grafico();
			grafico.x = grafX;
			grafico.y = grafY;
			grafico.visible = grafVisible;
			addChild(grafico);
		}
		
		function GLOBAL_play( e:Event ) //INICIA A RECURSÃO
		{
			trace("GLOBAL_PLAY");
			if( Estado == "stop" )
			{
				menu.control.btn_pause.Enable();
				menu.control.btn_stop.Enable();
				menu.control.btn_play.Disable();
				Estado = "play"; //SETA O STATE
				menu.opt.Lock(); //TRANCA O MENU DE OPÇÕES
				gravidade = Number(menu.opt.TXT_grav.text); //SETA O VALOR DA GRAVIDADE DE ACORDO COM O CAMPO DE TEXTO
				intervalo = setInterval( funcRecursiva, FPS ); //CRIA A FUNÇÃO RECURSIVA
			}
			
			seta.visible = true;
		}
		
		function GLOBAL_pause( e:Event ) //PAUSA A RECURSÃO
		{
			trace("GLOBAL_PAUSE");

				menu.control.btn_play.Enable();
				Estado = "stop";
				clearInterval( intervalo );
		}
		
		function GLOBAL_stepPlay( e:Event ) //EXECUTA A RECURSÃO PASSO A PASSO
		{
			trace("GLOBAL_STEPPLAY");

			Estado = "stop";
			menu.control.btn_pause.Disable();
			menu.control.btn_play.Enable();
			menu.control.btn_stop.Enable();
			clearInterval( intervalo );

			funcRecursiva();
		}
		
		function GLOBAL_controlGrafico( e:Event )
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
		
		function plotarGrafico(velocidade:Number):Shape
		{
			if ((tempo_ms/50) < 110) //Caso os valores não ultrapassem o limite do gráfico.
			{
				var ponto:Shape = new Shape();
				ponto.graphics.beginFill(0xCC0000, 0.5);			//Inicia o preenchimento do ponto que será adicionado na tela.
				ponto.graphics.drawCircle((tempo_ms / 30) + 36, velocidade * ( -1) + 139, 1);	//Define o x e y do ponto que será plotado; as coordenadas são baseadas no instante da velocidade.
																                                //O tempo (ponto x) é dividido por 30 para caber no Movie Clip "grafico".
																								//A velocidade (ponto y) é multiplicada por (-1) para inverter o plano cartesiano.
																								//NOTA: AS CONSTANTES 36 e 139 corrigem o ponto de origem do MovieClip para que sejam plotados exatamente dentro do campo de análise.
															

				
				ponto.graphics.endFill();			    //termina o preenchimento.
				return ponto;							//retorna o ponto que será plotado.
			}
			else 
			{
				return null;
			}
		}		
		
		function desabilitar_bottons()
		{
			menu.control.btn_stop.Disable();
			menu.control.btn_pause.Disable();
			menu.control.btn_play.Enable();
		}
		
		function habilitar_bottons()
		{
			menu.control.btn_stop.Enable();
			menu.control.btn_pause.Enable();
			menu.control.btn_play.Disable();
		}
	}
}