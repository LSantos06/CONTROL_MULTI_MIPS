# CONTROL_MULTI_MIPS
###Trabalho 7 de Organizacão e Arquitetura de Computadores

## Objetivo
Projetar, simular e sintetizar a parte de controle do **MIPS Multiciclo**, usando uma estrutura baseada na solução microprogramada, no ambiente *Quartus* / *ModelSim-Altera*.
  
## Gerando um arquivo TestBench pelo *Quartus II*
  - Vá em **Assignments->Settings->EDA Tool Settings->Simulation** e verifique a ferramenta que será utilzada para a simulação, especifique o diretório em que o *Test Bench* será gerado (padrão = *simulation\modelsim\*), e desligue a opção de *NativeLink*;
  - Clique em **Processing->Start->Start Test Bench Template Writer**;
  - Edite o aqruivo gerado no diretório especificado de acordo com suas necessidades.
  
## Simulação utilizando o *ModelSim*
  - Crie um projeto no menu **File->New->Project...**, adicione os arquivos **.VHD** e **.VHT** ao projeto criado;
  - Compile os arquivos selecionando no menu **Compile**, a opção **Compile Order**, e logo em seguida **Auto Generate**;
  - Inicialiaze a simulação clicando no menu **Simulate->Start Simulation...** e selecionando o *Test Bench* (arquivo **.VHT**) para a simulação;
  - Adicione os sinais desejados na **Wave** clicando com o botão direito no sinal, e logo depois em **Add to..->Wave->Signals in Design**.  
  - Clique em **View->Wave** para visualizar os sinais adicionados na tela;
  - Vá ao menu **Simulate** e clique em **Run**.
