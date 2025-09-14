# Windows PowerShell용 Bastion 접속 스크립트
# 사용법: .\connect-bastion.ps1 [project-name] [environment]

param(
    [string]$ProjectName = "your-project",
    [string]$Environment = "dev"
)

Write-Host "🔑 AWS SSM에서 Private Key 가져오는 중..." -ForegroundColor Yellow
$ParamName = "/charon/$ProjectName/$Environment/bastion/private-key"

try {
    # Private key 다운로드
    $PrivateKey = aws ssm get-parameter --name $ParamName --with-decryption --query "Parameter.Value" --output text
    
    if ($LASTEXITCODE -ne 0) {
        throw "AWS SSM Parameter를 가져올 수 없습니다."
    }
    
    # Private key를 파일로 저장
    $PrivateKey | Out-File -FilePath "bastion-key.pem" -Encoding ASCII
    
    Write-Host "🌐 Bastion Public IP 확인 중..." -ForegroundColor Yellow
    # Terraform output에서 IP 가져오기
    $BastionIP = terraform output -raw bastion_public_ip 2>$null
    
    if ([string]::IsNullOrEmpty($BastionIP)) {
        throw "Bastion Public IP를 찾을 수 없습니다."
    }
    
    Write-Host "🚀 Bastion에 접속합니다: $BastionIP" -ForegroundColor Green
    Write-Host "접속 후 Private Key 파일을 삭제합니다..." -ForegroundColor Yellow
    
    # SSH 접속 (Windows에서 OpenSSH 사용)
    ssh -i bastion-key.pem ec2-user@$BastionIP
    
} catch {
    Write-Host "❌ 오류: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # 접속 종료 후 private key 삭제
    if (Test-Path "bastion-key.pem") {
        Remove-Item "bastion-key.pem" -Force
        Write-Host "🗑️ Private Key 파일이 삭제되었습니다." -ForegroundColor Green
    }
}