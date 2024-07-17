//------------------------------------------------------------------------------------------------------------
//********* Sobre ************
//Autor: Gisele de Melo
//Esse código foi desenvolvido com o intuito de aprendizado para o blog codedelphi.com, portanto não me
//responsabilizo pelo uso do mesmo.
//
//********* About ************
//Author: Gisele de Melo
//This code was developed for learning purposes for the codedelphi.com blog, therefore I am not responsible for
//its use.
//------------------------------------------------------------------------------------------------------------

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.SyncObjs, Generics.Collections, Vcl.ComCtrls;

const
  WM_UPDATE = WM_USER + 1;

type

  //Eventos
  TMyThread1 = class(TThread)
  private
    FEvent: TEvent;
    FData: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    property Data: Integer read FData;
  end;

  //Mensagens
  TMyThread2 = class(TThread)
  private
    FHandle: HWND;
  protected
    procedure Execute; override;
  public
    constructor Create(AHandle: HWND);
  end;

  //Recursos Compartilhados com Sincronização
  TMyThread3 = class(TThread)
  private
    FUpdateMethod: TThreadProcedure;
  protected
    procedure Execute; override;
  public
    constructor Create(UpdateMethod: TThreadProcedure);
  end;

  //Queue(Fila)
  TTaskQueue = class
  private
    FQueue: TQueue<Integer>;
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddTask(Value: Integer);
    function GetNextTask: Integer;
  end;

  TProducerThread = class(TThread)
  private
    FTaskQueue: TTaskQueue;
    FTaskCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(TaskQueue: TTaskQueue; TaskCount: Integer);
  end;

  TConsumerThread = class(TThread)
  private
    FTaskQueue: TTaskQueue;
    FUpdateMethod: TThreadProcedure;
  protected
    procedure Execute; override;
  public
    constructor Create(TaskQueue: TTaskQueue; UpdateMethod: TThreadProcedure);
  end;

  //Formulário
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Mensagens: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Memo1: TMemo;
    Button4: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    TaskQueue: TTaskQueue;

    procedure WndProc(var Msg: TMessage); override;
    procedure UpdateUI;
    procedure UpdateLog;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  CriticalSection: TCriticalSection;
  SharedResource: Integer;

implementation

{$R *.dfm}

{ TMyThread1 }

constructor TMyThread1.Create;
begin
  inherited Create(True); // Cria a thread suspensa
  FEvent := TEvent.Create(nil, False, False, ''); // Inicializa o evento
end;

destructor TMyThread1.Destroy;
begin
  if Assigned(FEvent) then
    FEvent.Free; //Finaliza o evento
  inherited;
end;

procedure TMyThread1.Execute;
begin
  Sleep(1000); // Simula trabalho
  FData := 42; // Define um valor
  FEvent.SetEvent; // Sinaliza que o trabalho foi concluído
end;

{ TMyThread2 }

constructor TMyThread2.Create(AHandle: HWND);
begin
  inherited Create(False);
  FreeOnTerminate := True; //Finaliza assim que terminar de Executar
  FHandle := AHandle;
end;

procedure TMyThread2.Execute;
begin
  // Simular uma operação de longa duração
  Sleep(3000);
  // Enviar mensagem para a interface gráfica
  PostMessage(FHandle, WM_UPDATE, 0, 0);
end;

{ TMyThread3 }

constructor TMyThread3.Create(UpdateMethod: TThreadProcedure);
begin
  inherited Create(True); // Create suspended
  FUpdateMethod := UpdateMethod;
  FreeOnTerminate := True;
end;

procedure TMyThread3.Execute;
begin
  CriticalSection.Enter;
  try
    SharedResource := SharedResource + 1; // Acesso seguro
    Sleep(1000); //Espera 1 segundo para dar tempo de exibir o incremento na interface gráfica
    Synchronize(FUpdateMethod); // Atualizar a interface de forma segura
  finally
    CriticalSection.Leave;
  end;
end;

{ TTaskQueue }

constructor TTaskQueue.Create;
begin
  FQueue := TQueue<Integer>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TTaskQueue.Destroy;
begin
  FQueue.Free;
  FLock.Free;
  inherited;
end;

procedure TTaskQueue.AddTask(Value: Integer);
begin
  FLock.Enter;
  try
    FQueue.Enqueue(Value);
  finally
    FLock.Leave;
  end;
end;

function TTaskQueue.GetNextTask: Integer;
begin
  FLock.Enter;
  try
    if FQueue.Count > 0 then
      Result := FQueue.Dequeue
    else
      Result := -1; // ou algum valor padrão
  finally
    FLock.Leave;
  end;
end;

{ TProducerThread }

constructor TProducerThread.Create(TaskQueue: TTaskQueue; TaskCount: Integer);
begin
  inherited Create(True);
  FTaskQueue := TaskQueue;
  FTaskCount := TaskCount;
  FreeOnTerminate := True;
end;

procedure TProducerThread.Execute;
var
  I: Integer;
begin

  for I := 1 to FTaskCount do
  begin
    FTaskQueue.AddTask(I);
    Sleep(100); // Simula algum trabalho
  end;

end;

{ TConsumerThread }

constructor TConsumerThread.Create(TaskQueue: TTaskQueue; UpdateMethod: TThreadProcedure);
begin
  inherited Create(True);
  FTaskQueue := TaskQueue;
  FUpdateMethod := UpdateMethod;
  FreeOnTerminate := True;
end;

procedure TConsumerThread.Execute;
var
  Task: Integer;

begin

  while not Terminated do
  begin
    Task := FTaskQueue.GetNextTask;
    if Task <> -1 then
    begin
      // Processar a tarefa
      Sleep(150); // Simula algum trabalho

      // Atualizar a interface
      Synchronize(FUpdateMethod);
    end
    else
    begin
      // Sem tarefas, dormir um pouco
      Sleep(50);
    end;
  end;

end;

procedure TForm1.UpdateLog;
begin
  Memo1.Lines.Add('Task processed by consumer.');
end;

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
// Para usar a thread:
var
  MyThread: TMyThread1;
begin
  MyThread := TMyThread1.Create;//Cria a Thread
  try
    MyThread.Start;//Inicia a Thread
    MyThread.FEvent.WaitFor(INFINITE); // Aguarda o evento
    ShowMessage('Dado recebido: ' + IntToStr(MyThread.Data)); //Exibe a mensagem
  finally
    MyThread.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // Iniciar a thread e passar o handle do formulário
  TMyThread2.Create(Self.Handle);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  i: Integer;
begin
  SharedResource := 0;
  for i := 1 to 5 do
  begin
    TMyThread3.Create(UpdateUI).Start;
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  ProducerThread: TProducerThread;
  ConsumerThread: TConsumerThread;

begin
  Memo1.Lines.Clear;
  TaskQueue := TTaskQueue.Create;

  // Criar e iniciar threads produtoras e consumidoras
  ProducerThread := TProducerThread.Create(TaskQueue, 10);
  ConsumerThread := TConsumerThread.Create(TaskQueue, UpdateLog);

  ProducerThread.Start;
  ConsumerThread.Start;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CriticalSection := TCriticalSection.Create; //Cria a instância de sessão crítica
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(CriticalSection) then
    CriticalSection.Free;//Finaliza a instância de sessão crítica
end;

procedure TForm1.UpdateUI;
begin
  //Atualiza a interface gráfica com os dados compartilhados
  Label1.Caption := 'SharedResource value: ' + SharedResource.ToString;
end;

procedure TForm1.WndProc(var Msg: TMessage);
begin
  inherited WndProc(Msg);
  if Msg.Msg = WM_UPDATE then //Verifica se a mensagem foi recebida e exibe a mensagem
    ShowMessage('Mensagem recebida de outra thread!');
end;

end.
