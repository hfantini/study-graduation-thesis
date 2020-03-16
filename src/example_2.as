package
{
	//IMPORT LIBS
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.setInterval;
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flashx.textLayout.formats.Float;
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	import fl.transitions.TweenEvent;

	public class GravidadeU extends MovieClip
	{
		//VARIÁVEIS
		
			//ENGINE
			private var tempo_ms:Number = 0;		
			private var tempo_seg:Number = 0;
			private var intervalo:Number;
			private var scaleXtween:Tween;
			private var scaleYtween:Tween;
			private var scaleAlphaTween:Tween;
			
			//MECÂNICA
			
			private var FPS:int = 41;
			private var iniX:Number;
			private var iniY:Number;
			private var Xtween:Boolean = true;
			private var Ytween:Boolean = true;
			private var Alphatween:Boolean = true;
			private var raio_gravidade = 300;
			private var gseta;
			private var seta_bool = true;
			private var Y_seta:Number;
			private var X_seta:Number;
			private var razaoDistancia_seta:Number = 0;
			private var Y_seta_inicial:Number;
			private var tangente_seta:Number;
			private var limitSet:String;
			private var angulo_seta:Number;
			private var distancia_seta:Number;
			private var direcao_seta:Number;
			private var catetoY_seta:Number;
			private var catetoX_seta:Number;
			var mov_gravidade:gTraco = new gTraco();
			var mov_areagravidade:gArea = new gArea();
			var containerDesenho:Sprite = new Sprite();
			private var cor:uint = 0xFF115500;
			

			
			//ATIVIDADE
			private const InicialLuaX = 671;
			private const InicialLuaY = 139;
			private var const_gravitacional = 6.67; //CONSTANTE GRAVITACIONAL DE NEWTON
			private var massa_lua = 200;
			private var massa_terra = 1500;
			private var angulo:Number;
			private var tangente:Number;
			private var sentidoX:Number;
			private var sentidoY:Number;
			private var porcentoX:Number;
			private var porcentoY:Number;
			private var catetoX:Number;
			private var catetoY:Number;
			private var distancia;
			private var InicialVeloX:Number = 12;
			private var InicialVeloY:Number = 12;
			private var aceleracaoX:Number = 0;
			private var aceleracaoY:Number = 0;
			private var velocidadeX:Number = 0;
			private var velocidadeY:Number = 0;
			private var velocidadeTotal:Number = 0;


		public function GravidadeU()
		{
			
			//Define padrões da mecânica da atividade.
			menu.btn_graf.Lock();
			menu.btn_trace.Unlock();
			menu.btn_eraseTrace.Unlock();
			
			//Define padrões nas opções
			menu.opt.TXT_grav.text = const_gravitacional.toString();
			menu.opt.TXT_veloY.text = InicialVeloX.toString();
			menu.opt.TXT_veloX.text = InicialVeloY.toString();
			menu.opt.TXT_gRaio.text = raio_gravidade.toString();
			menu.opt.TXT_planeta.text = massa_terra.toString();
			menu.opt.TXT_lua.text = massa_lua.toString();
						
			//Define valores do ambiente
			mov_areagravidade.height = raio_gravidade;
			mov_areagravidade.width = raio_gravidade;
			mov_areagravidade.x = 13;
			mov_areagravidade.y = 13;
			mov_areagravidade.alpha = -100;
			planeta.addChild(mov_areagravidade);

			mov_gravidade.x = 0;
			mov_gravidade.y = 0;
			planeta.addChild(mov_gravidade);
						
			//FUNCTIONS
			animar_grav( raio_gravidade );
			
			//LISTENERS
			this.addEventListener("STOP", GLOBAL_stop);
			this.addEventListener("PLAY", GLOBAL_play);
			this.addEventListener("PAUSE", GLOBAL_pause);
			this.addEventListener("STEP_PLAY", GLOBAL_stepPlay);
			this.addEventListener("CONTROLE_TRACO", GLOBAL_controlTraco);
			this.addEventListener("CONTROLE_APAGAR-TRACO", GLOBAL_TraceErase);
			
			
			addChild(containerDesenho);
			this.setChildIndex(containerDesenho, 0);
			containerDesenho.visible = false;	
		}
		
		//FUNÇÃO RECURSIVA
		
		private function funcRecursiva() //FUNÇÃO PRINCIPAL DA ATIVIDADE
		{
			
			//CALCULO DE ESTATISTICAS
			tempo_ms += FPS; //Tempo em Milissegundos.
			tempo_seg = Math.floor(tempo_ms / 1000); //Tempo em segundos.
															
			//REALIZA CALCULO DAS CONDIÇÕES DO CORPO
			if( lua.hitTestObject( mov_areagravidade ) ) // Testa se o corpo está no raio da gravidade exercida pelo planeta
			{
				//CALCULA A TANGENTEv 
				//A TANGENTE REPRESENTA O ANGULO DE INCLINAÇÃO DESTA RETA FICTÍCIA
				
				catetoY = planeta.y - lua.y ;
				catetoX = lua.x - planeta.x ;
				
				tangente = ( catetoY ) / (catetoX ); //CALCULO DE TANGENTE DA RETA
				angulo = Math.round( Math.atan(tangente)/(Math.PI / 180 ));  //CALCULA O ANGULO E O CONVERTE DE RADIANOS PARA GRAUS
				
				//TRATAMENTO DO ANGULO (REALIZA UM TRATAMENTO PARA OBTERMOS UM VALOR REAL DE 360º)
				if( lua.x < planeta.x )
				{
					angulo += 180;
				}
				else if (lua.x >= planeta.x && lua.y > planeta.y) 
				{
					angulo += 360;
				}
				
				//DETERMINA O SENTIDO DO CORPO (DIREÇÃO)
				if( angulo >= 0 && angulo <= 90)
				{
					sentidoX = -1;
					sentidoY = 1;
				}
				else if( angulo > 90 && angulo <= 180 )
				{
					sentidoX = 1;
					sentidoY = 1;
					angulo -= 180; //RETORNA O ANGULO PARA O ESTADO PRIMÁRIO (INTERVALO DE 0º ATÉ 90º)
				}
				else if( angulo > 180 && angulo <= 270 )
				{
					sentidoX = 1;
					sentidoY = -1;
					angulo -= 180; //RETORNA O ANGULO PARA O ESTADO PRIMÁRIO (INTERVALO DE 0º ATÉ 90º)
				}
				else if( angulo > 270 && angulo <= 360)
				{
					sentidoX = -1;
					sentidoY = -1;
					angulo -= 360; //RETORNA O ANGULO PARA O ESTADO PRIMÁRIO (INTERVALO DE 0º ATÉ 90º)
				}

				//MANTEM O VALOR DO ANGULO POSITIVO
				if (angulo < 0)
					angulo = angulo * -1;

				//DETERMINA A TAXA DE FORÇA EXERCIDA PELA GRAVIDADE EM AMBOS OS EIXOS DO CORPO | UTILIZA-SE UMA PORCENTAGEM DO ANGULO SOBRE 90						
				distancia = Math.round( Math.sqrt( Math.pow( catetoX, 2 ) + Math.pow( catetoY, 2 ) ) ); //CALCULA O VALOR DA DISTÂNCIA DA LUA PARA O PLANETA | Teorema de pitágoras: H^2 = C^2 + C^2
				
				var forca = (const_gravitacional / 9.8) * (	(massa_lua * massa_terra) / Math.pow( distancia , 2 ) ); 
				//LEI DA GRAVITAÇÃO UNIVERSAL | Baseada na 1ª lei de Newton
				 //FORMULA: Constante de gravidade universal * [ (MassaA * MassaB) / Distância^2 ]				
																											 
				var aceleracao = forca / massa_lua;	//CALCULA-SE A ACELERAÇÃO UTILIZANDO O INVERSO DA FORMULA DA FORÇA : Força = Massa * aceleração |
													//Neste caso, utiliza-se Aceleração = Força / massa
													
				//porcentoY = Math.round( (angulo / 90) * 100 ); //DETERMINA QUANTIDADE DE VELOCIDADE GRAVITACIONAL EXCERCIDA NO EIXO Y;
				//porcentoX = 100 - porcentoY; //DETERMINA QUANTIDADE DE VELOCIDADE GRAVITACIONAL EXCERCIDA NO EIXO X	
				
				porcentoX = Math.cos(angulo / 180 * Math.PI)*100;
				porcentoY = Math.sin(angulo / 180 * Math.PI)*100;	
				
				//APLICA A QUANTIDADE DE ACELERAÇÃO DETERMINADA PELA PORCENTAGEM EM RELAÇÃO AO ANGULO ENTRE OS DOIS CORPOS
				aceleracaoY = (porcentoY * aceleracao) / 100; //EIXO X
				aceleracaoX = (porcentoX * aceleracao) / 100; //EIXO Y
								
				//ACRESCENTA NA VELOCIDADE DO CORPO O VALOR DA ACELERAÇÃO DO EIXO MULTIPLICADO PELO SENTIDO PARA DETERMINAR A DIREÇÃO
				velocidadeX += aceleracaoX * sentidoX; //EIXO X
				velocidadeY += aceleracaoY * sentidoY; //EIXO Y
				
				velocidadeTotal = velocidadeX + velocidadeY + (InicialVeloX / 9.8) + (InicialVeloY / 9.8); //CALCULA A VELOCIDADE TOTAL DO OBJETO | SOMA DAS VELOCIDADES X E Y

			}
			else //SE NÃO ESTIVER SOBRE EFEITO DA GRAVIDADE, A DISTANCIA DEVE SER CALCULADA DA MESMA FORMA.
			{
				catetoY = planeta.y - lua.y ;
				catetoX = lua.x - planeta.x ;	
				
				distancia = Math.round( Math.sqrt( Math.pow( catetoX, 2 ) + Math.pow( catetoY, 2 ) ) ); //CALCULA O VALOR DA DISTÂNCIA DA LUA PARA O PLANETA | Teorema de pitágoras: H^2 = C^2 + C^2
			}
			lua.x += velocidadeX + ( InicialVeloX / 9.8 );
			lua.y += velocidadeY + ( InicialVeloY / 9.8 );
							
			//DETERMINA A ENTRADA DA LUA NO OFFSTAGE E PLOTA A SETA NO PALCO

			if( lua.x < 230 && lua.y > 0 && lua.y < 500 )
			{
				limitSet = "LEFT";
			}
			else if (lua.x > 900 && lua.y > 0 && lua.y < 500  )
			{
				limitSet = "RIGHT";
			}
			else if ( lua.y < 0  )
			{
				limitSet = "UP";
			}
			else if (lua.y > 500)
			{
				limitSet = "DOWN";
			}
			else 
			{
				limitSet = "NONE";
			}

			if( limitSet != "NONE" )
			{		
				
				switch(limitSet)
				{
					case "UP":
						criar_seta();
						seta_effect_up();
						break;
						
					case "DOWN":
						criar_seta();
						seta_effect_down();
						break;
						
					case "LEFT":
						criar_seta();
						seta_effect_left();
						break;
						
					case "RIGHT":
						criar_seta();
						seta_effect_right();
						break;
						
				}
				
				seta_bool = false;

			}
			
			else
			{
				if ( gseta != null )
				{
					limitSet = "NONE";
					this.removeChild(gseta);
					gseta = null;
					seta_bool = true;
				}
			}
	
			if( planeta.hitTestObject(lua) )
			{
				trace("colidiu");
			}

			//ATUALIZA ESTATÍSTICAS
			
			plotarTragetoria();
			atualizaInfo();
		}
		
		function atualizaInfo()
		{
			menu.infor.TXT_ms.text = tempo_ms.toString() + " ms";
			menu.infor.TXT_seg.text = tempo_seg.toString() + " seg";
			menu.infor.TXT_dist.text = distancia.toString() + " P";
			menu.infor.TXT_velo.text = String( velocidadeTotal.toFixed(2) ) + " Px/r";
			
		}
		
		function clearInfo()
		{
			menu.infor.TXT_ms.text = "";
			menu.infor.TXT_seg.text = "";
			menu.infor.TXT_dist.text = "";
			menu.infor.TXT_velo.text = "";
		}
		
		function animar_grav( gRaio:Number )
		{
			var proporcao = gRaio / 100;
			
			if( Xtween && Ytween && Alphatween )
			{
				scaleXtween = new Tween(mov_gravidade,"scaleX", Regular.easeIn,1, proporcao ,1,true) ;
				scaleYtween = new Tween(mov_gravidade,"scaleY",Regular.easeIn,1, proporcao ,1,true) ;
				scaleAlphaTween = new Tween(mov_gravidade,"alpha",Regular.easeOut, 100 ,0 ,1,true) ;
				
				Alphatween = false;
				Xtween = false;
				Ytween = false;
				
				scaleXtween.addEventListener(TweenEvent.MOTION_FINISH, grav_evt_X );
				scaleYtween.addEventListener(TweenEvent.MOTION_FINISH, grav_evt_Y );
				scaleAlphaTween.addEventListener(TweenEvent.MOTION_FINISH, grav_evt_alpha );
			}
		}
		
		function plotarTragetoria()
		{
			//PLOTA A TRAGETÓRIA DO CORPO
			
			containerDesenho.graphics.lineStyle(1, cor);			
			containerDesenho.graphics.lineTo(lua.x, lua.y);
		}
		
		//EVENTOS
		
		function GLOBAL_stop( e:Event ) //REINICIA A RECURSÃO
		{
			trace("GLOBAL_STOP");

			//CONTROLES
			menu.control.btn_pause.Disable();
			menu.control.btn_stop.Disable();
			menu.control.btn_play.Enable();
			menu.opt.Unlock();
			
			//RESETA VALORES
			lua.x = InicialLuaX;
			lua.y = InicialLuaY;
		    aceleracaoX = 0;
			aceleracaoY = 0;
			velocidadeX = 0;
			velocidadeY = 0;		
			tempo_ms = 0;
			tempo_seg = 0;
			clearInfo();
			isNotLocked = true;
			cor = Math.random() * 0xFFFFFF;
			seta_bool = true;
			
			if(gseta != null)
			{
				limitSet = null;
				gseta.visible = false;
			}
			
			clearInterval( intervalo );
		}
		
		function GLOBAL_play( e:Event ) //INICIA A RECURSÃO
		{
			trace("GLOBAL_PLAY");

				menu.control.btn_pause.Enable();
				menu.control.btn_stop.Enable();
				menu.control.btn_play.Disable();
				isNotLocked = false;
				menu.opt.Lock(); //TRANCA O MENU DE OPÇÕES
				
				const_gravitacional = Number(menu.opt.TXT_grav.text); //SETA O VALOR DA GRAVIDADE DE ACORDO COM O CAMPO DE TEXTO
				InicialVeloX = Number(menu.opt.TXT_veloX.text);
				InicialVeloY = Number(menu.opt.TXT_veloY.text);
				raio_gravidade = Number(menu.opt.TXT_gRaio.text);
				massa_terra = Number(menu.opt.TXT_planeta.text);
				massa_lua = Number(menu.opt.TXT_lua.text);
				
				//RESETA CAMPO GRAVITACIONAL
				
				planeta.removeChild(mov_areagravidade);
				mov_areagravidade.height = raio_gravidade;
				mov_areagravidade.width = raio_gravidade;
				mov_areagravidade.x = 0;
				mov_areagravidade.y = 0;
				mov_areagravidade.alpha = -100;
				planeta.addChild(mov_areagravidade);
	
			    planeta.removeChild(mov_gravidade);
				mov_gravidade.x = 0;
				mov_gravidade.y = 0;
				planeta.addChild(mov_gravidade);
				
				// O método setInterval fará a recursividade da função funcRecursiva, definindo um atraso de 41ms entre suas iterações;
				// 41ms equivale a aproximadamente 24fps			
				//intervalo = setInterval( funcRecursiva, 41 );
				
				containerDesenho.graphics.moveTo(lua.x, lua.y);
				
				intervalo = setInterval( funcRecursiva, FPS ); //CRIA A FUNÇÃO RECURSIVA
		}
		
		function GLOBAL_pause( e:Event ) //PAUSA A RECURSÃO
		{
			trace("GLOBAL_PAUSE");
				
				isNotLocked = true;
				menu.control.btn_play.Enable();
				clearInterval( intervalo );
		}
		
		function GLOBAL_stepPlay( e:Event ) //EXECUTA A RECURSÃO PASSO A PASSO
		{
			trace("GLOBAL_STEPPLAY");

			isNotLocked = true;
			menu.control.btn_pause.Disable();
			menu.control.btn_play.Enable();
			menu.control.btn_stop.Enable();
			clearInterval( intervalo );

			funcRecursiva();
		}
		
		function GLOBAL_controlTraco( e:Event )
		{		
			if( menu.btn_trace.getButtonState() == "Pressed" )
			{
				containerDesenho.visible = true;
			}
			else if( menu.btn_trace.getButtonState() == "Normal" )
			{
				containerDesenho.visible = false;
			}
		}
		
		function GLOBAL_TraceErase( e:Event )
		{
			if (contains(containerDesenho)) 
			{
				containerDesenho.graphics.clear();
				containerDesenho.graphics.moveTo(lua.x, lua.y);
			}
		}
		
		function grav_evt_X( e:TweenEvent )
		{			
			Xtween = true;
			scaleXtween.removeEventListener(TweenEvent.MOTION_FINISH, grav_evt_X );
			animar_grav( raio_gravidade );
		}
	
		function grav_evt_Y( e:TweenEvent )
		{			
			Ytween = true;
			scaleYtween.removeEventListener(TweenEvent.MOTION_FINISH, grav_evt_X );
			animar_grav( raio_gravidade );
		}
		
		function grav_evt_alpha( e:TweenEvent )
		{			
			Alphatween = true;
			scaleAlphaTween.removeEventListener(TweenEvent.MOTION_FINISH, grav_evt_X );
			animar_grav( raio_gravidade );
		}
		
		function criar_seta()
		{
			if (seta_bool)
			{
				gseta = new gSeta();
				gseta.x = 0;
				gseta.y = 0;
				gseta.visible = false;
				this.addChild(gseta);
				gseta.visible = false;
				
				switch( limitSet )
				{
					case "UP":	
						X_seta = lua.x;
						Y_seta = 10;
						gseta.txt.rotation = 90;
						gseta.txt.scaleX *= -1;
						gseta.txt.scaleY *= -1;
						break;
						
					case "LEFT":
						Y_seta = lua.y;
						X_seta = 240;
						break;
						
					case "RIGHT":
						Y_seta = lua.y;
						X_seta = 890;
						break;
						
					case "DOWN":
						X_seta = lua.x;
						Y_seta = 490;
						gseta.txt.rotation = 90;
						break;
				}
				
				seta_bool = false;
			}
		}
		
		//EFEITOS DA SETA
		function seta_effect_up()
		{					
						
				//DISTANCIA E ANGULAÇÃO				
				var catetoY_seta = lua.y - gseta.y;
				var catetoX_seta = gseta.x - lua.x;
				var tangente_seta = ( catetoY_seta ) / ( catetoX_seta ); //CALCULO DE TANGENTE DA RETA
				var angulo_seta = Math.round( Math.atan( tangente_seta )/(Math.PI / 180 ));  //CALCULA O ANGULO E O CONVERTE DE RADIANOS PARA GRAUS
				
				var distancia_seta = distancia = Math.round( Math.sqrt( Math.pow( catetoY_seta, 2 ) + Math.pow( catetoX_seta, 2 ) ) );

				//DETERMINANDO DIREÇÃO DA SETA										
				var razaoDistancia_seta = ( (X_seta - lua.x) / 50);

				if( razaoDistancia_seta < 0)
				{
				   	X_seta -= razaoDistancia_seta;
					angulo_seta = 180 - angulo_seta;
				}
				else
				{
					X_seta -= razaoDistancia_seta;
					angulo_seta = 360 - angulo_seta;
				}
						
				//TRATANDO A COLISÃO DA SETA COM OS LIMITES LATERAIS
				if( X_seta < 240 )
				{
					X_seta = 240;
				}
				else if( X_seta > 890 )
				{
					X_seta = 890;
				}
				
				//DETERMINA SE A SETA AINDA PRECISA SER MOVIMENTADA NO EIXO Y
				if (Y_seta > 10 && X_seta > lua.x)
				{
					Y_seta--;
				}
				else
				{
					Y_seta = 10;
				}
				
				if (Y_seta < 890 && Y_seta < lua.x)
				{
					Y_seta++;
				}
				else
				{
					Y_seta = 10;
				}
				
				
				gseta.txt.distancia.text = distancia_seta.toString() + " Px";
				gseta.rotation = (angulo_seta);
				
				//ATUALIZA A SETA
				gseta.x = X_seta;
				gseta.y = Y_seta;
				
			    gseta.visible = true;

		}
		
		function seta_effect_down()
		{
			trace("OFFSET DOWN");
			
				//DISTANCIA E ANGULAÇÃO				
				var catetoY_seta = lua.y - gseta.y;
				var catetoX_seta = gseta.x - lua.x;
				var tangente_seta = ( catetoY_seta ) / ( catetoX_seta ); //CALCULO DE TANGENTE DA RETA
				var angulo_seta = Math.round( Math.atan( tangente_seta )/(Math.PI / 180 ));  //CALCULA O ANGULO E O CONVERTE DE RADIANOS PARA GRAUS
				
				var distancia_seta = distancia = Math.round( Math.sqrt( Math.pow( catetoY_seta, 2 ) + Math.pow( catetoX_seta, 2 ) ) );

				//DETERMINANDO DIREÇÃO DA SETA										
				razaoDistancia_seta = ( (X_seta - lua.x) / 50);

				if( razaoDistancia_seta < 0)
				{
				   	X_seta -= razaoDistancia_seta;
					angulo_seta = 180 - angulo_seta;
				}
				else
				{
					X_seta -= razaoDistancia_seta;;
					angulo_seta = 360 - angulo_seta;
				}
						
				//TRATANDO A COLISÃO DA SETA COM OS LIMITES LATERAIS
				if( X_seta < 240 )
				{
					X_seta = 240;
				}
				else if( X_seta > 890 )
				{
					trace("test");
					X_seta = 890;
				}
				
				//DETERMINA SE A SETA AINDA PRECISA SER MOVIMENTADA NO EIXO Y
				if (Y_seta < 490 && X_seta < lua.x)
				{
					Y_seta++;
				}
				else
				{
					Y_seta = 490;
				}
				
				gseta.txt.distancia.text = distancia_seta.toString() + " Px";
				gseta.rotation = (angulo_seta);
				
				//ATUALIZA A SETA
				gseta.x = X_seta;
				gseta.y = Y_seta;
				
			    gseta.visible = true;

		}
		
		function seta_effect_right()
		{
			
			trace("OFFSET RIGHT");
				
				//DETERMINANDO DIREÇÃO DA SETA										
				razaoDistancia_seta = ( (Y_seta - lua.y) / 50);

				if( razaoDistancia_seta < 0)
				{
				   	Y_seta -= razaoDistancia_seta;
					angulo_seta = 180 - angulo_seta;
				}
				else
				{
					Y_seta -= razaoDistancia_seta;;
					angulo_seta = 360 - angulo_seta;
				}
				
				//TRATANDO A COLISÃO DA SETA COM OS LIMITES LATERAIS
				if( Y_seta < 10 )
				{
					Y_seta = 10;
				}
				else if( Y_seta > 490 )
				{
					Y_seta = 490;
				}
				 
				//DETERMINA SE A SETA AINDA PRECISA SER MOVIMENTADA NO EIXO X
				
				if (X_seta < 890 && Y_seta > lua.y)
				{
					X_seta--;
				}
				else
				{
					X_seta = 890;
				}
				
				//DISTANCIA E ANGULAÇÃO				
				catetoY_seta = gseta.y - lua.y ;
				catetoX_seta = lua.x - gseta.x ;
				tangente_seta = ( catetoY_seta ) / ( catetoX_seta ); //CALCULO DE TANGENTE DA RETA
				angulo_seta = Math.round( Math.atan( tangente_seta )/(Math.PI / 180 ));  //CALCULA O ANGULO E O CONVERTE DE RADIANOS PARA GRAUS
				distancia_seta = distancia = Math.round( Math.sqrt( Math.pow( catetoY_seta, 2 ) + Math.pow( catetoX_seta, 2 ) ) );
								
				gseta.txt.distancia.text = distancia_seta.toString() + " Px";
				gseta.rotation = ( (angulo_seta + 180) * -1);	
				gseta.txt.rotation = 180;
				
				//ATUALIZA A SETA
				gseta.x = X_seta;
				gseta.y = Y_seta;		
				
				gseta.visible = true;	
		}
		
		function seta_effect_left()
		{			
				//DETERMINANDO DIREÇÃO DA SETA										
				razaoDistancia_seta = ( (Y_seta - lua.y) / 50);

				if( razaoDistancia_seta < 0)
				{
				   	Y_seta -= razaoDistancia_seta;
					angulo_seta = 180 - angulo_seta;
				}
				else
				{
					Y_seta -= razaoDistancia_seta;
					angulo_seta = 360 - angulo_seta;
				}
				
				//TRATANDO A COLISÃO DA SETA COM OS LIMITES SUPERIORES
				if( Y_seta < 10 )
				{
					Y_seta = 10;
				}
				else if( Y_seta > 490 )
				{
					Y_seta = 490;
				}
				   
				
				//DISTANCIA E ANGULAÇÃO				
				catetoY_seta = gseta.y - lua.y ;
				catetoX_seta = lua.x - gseta.x ;
				tangente_seta = ( catetoY_seta ) / ( catetoX_seta ); //CALCULO DE TANGENTE DA RETA
				angulo_seta = ( Math.round( Math.atan( tangente_seta )/(Math.PI / 180 ) ) );  //CALCULA O ANGULO E O CONVERTE DE RADIANOS PARA GRAUS
				distancia_seta = distancia = Math.round( Math.sqrt( Math.pow( catetoY_seta, 2 ) + Math.pow( catetoX_seta, 2 ) ) );
				
				gseta.txt.distancia.text = distancia_seta.toString() + " Px";
				gseta.rotation = ( angulo_seta * -1 );
				gseta.visible = true;
				
				//ATUALIZA A SETA
				gseta.x = X_seta;
				gseta.y = Y_seta;
		}
	}
}