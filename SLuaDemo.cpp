// dui-demo.cpp : main source file
//

#include "stdafx.h"
//从PE文件加载，注意从文件加载路径位置
#ifdef _DEBUG
#define SYS_NAMED_RESOURCE _T("soui-sys-resourced.dll")
#else
#define SYS_NAMED_RESOURCE _T("soui-sys-resource.dll")
#endif
#ifdef _DEBUG
#pragma comment(lib,"lua-53d")
#pragma comment(lib,"scriptmodule-luad")
#else
#pragma comment(lib,"lua-53")
#pragma comment(lib,"scriptmodule-lua")
#endif

using namespace SOUI;


class SOUIEngine
{
private:
	SComMgr m_ComMgr;
	SApplication *m_theApp;
	SouiFactory m_souiFac;
public:
	SOUIEngine():m_theApp(NULL){}
		
	BOOL Init(HINSTANCE hInstance){
		SAutoRefPtr<IRenderFactory> pRenderFactory;
		BOOL bLoaded = TRUE;
		do{
		//使用GDI渲染界面
		bLoaded = m_ComMgr.CreateRender_GDI((IObjRef * *)& pRenderFactory);
		SASSERT_FMT(bLoaded, _T("load interface [render] failed!"));
		if(!bLoaded) break;
		//设置图像解码引擎。默认为GDIP。基本主流图片都能解码。系统自带，无需其它库
		SAutoRefPtr<IImgDecoderFactory> pImgDecoderFactory;
		bLoaded = m_ComMgr.CreateImgDecoder((IObjRef * *)& pImgDecoderFactory);
		SASSERT_FMT(bLoaded, _T("load interface [%s] failed!"), _T("imgdecoder"));
		if(!bLoaded) break;

		pRenderFactory->SetImgDecoderFactory(pImgDecoderFactory);
		m_theApp = new SApplication(pRenderFactory, hInstance);	
		}while(false);
		return bLoaded;
	};
	//加载系统资源
	BOOL LoadSystemRes()
	{
		BOOL bLoaded = TRUE;
		do{
		//从DLL加载系统资源
		{
			HMODULE hModSysResource = LoadLibrary(SYS_NAMED_RESOURCE);
			if (hModSysResource)
			{
				IResProvider* sysResProvider = m_souiFac.CreateResProvider(RES_PE);
				sysResProvider->Init((WPARAM)hModSysResource, 0);
				m_theApp->LoadSystemNamedResource(sysResProvider);
				sysResProvider->Release();
				FreeLibrary(hModSysResource);
			}
			else
			{
				bLoaded = FALSE;
			}
			SASSERT(bLoaded);
			if(!bLoaded) break;
		}
		}while(false);
		return bLoaded;
	}

	//加载LUA支持
	BOOL LoadLUAModule()
	{
		BOOL bLoaded =FALSE;
		SAutoRefPtr<IScriptFactory> pScriptLuaFactory;
		bLoaded = m_ComMgr.CreateScrpit_Lua((IObjRef * *)& pScriptLuaFactory);
		SASSERT_FMT(bLoaded, _T("load interface [%s] failed!"), _T("scirpt_lua"));
		m_theApp->SetScriptFactory(pScriptLuaFactory);
		return bLoaded;
	}


	~SOUIEngine()
	{
		if (m_theApp)
		{
			delete m_theApp;
			m_theApp = NULL;
		}
	}

	SApplication* GetApp()
	{
		return m_theApp;
	}
};
//debug时方便调试设置当前目录以便从文件加载资源
void SetDefaultDir()
{
	TCHAR szCurrentDir[MAX_PATH] = { 0 };
	GetModuleFileName(NULL, szCurrentDir, sizeof(szCurrentDir));

	LPTSTR lpInsertPos = _tcsrchr(szCurrentDir, _T('\\'));
#ifdef _DEBUG
	_tcscpy(lpInsertPos + 1, _T("..\\SLuaDemo"));
#else
	_tcscpy(lpInsertPos + 1, _T("\0"));
#endif
	SetCurrentDirectory(szCurrentDir);
}

int WINAPI _tWinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPTSTR lpstrCmdLine, int /*nCmdShow*/)
{
	HRESULT hRes = OleInitialize(NULL);
	SASSERT(SUCCEEDED(hRes));
	SetDefaultDir();
	int nRet = 0;
	{
		SOUIEngine souiEngine;

		if (souiEngine.Init(hInstance))
		{
			//加载系统资源
			souiEngine.LoadSystemRes();
			//加载LUA脚本支持
			souiEngine.LoadLUAModule();

			SAutoRefPtr<IScriptModule> script;
			souiEngine.GetApp()->CreateScriptModule(&script);
			script->executeScriptFile("main.lua");
			TCHAR szDir[MAX_PATH];
			GetCurrentDirectory(MAX_PATH,szDir);
			SStringA strDir = S_CT2A(szDir,CP_UTF8);
			nRet = script->executeMain(hInstance,strDir.c_str(),NULL);
		}
		else
		{
			MessageBox(NULL, _T("无法正常初使化SOUI"), _T("错误"), MB_OK | MB_ICONERROR);
		}
	}
	OleUninitialize();
	return nRet;
}
