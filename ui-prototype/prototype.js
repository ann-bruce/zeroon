const screens = ['login', 'home', 'reset', 'success', 'archive', 'growth', 'states']
const descriptions = {
  login: '手机号验证码登录，保持入口安静且可信。',
  home: '3 秒内理解当前状态，并一键开始归零。',
  reset: '状态优先，文字可选，目标在 30 秒内完成。',
  success: '记录先保存，AI 反馈作为温和的额外价值。',
  archive: '私人时间线，不使用社交内容流的视觉语言。',
  growth: '展示共同走过的时间，不制造排名与打卡压力。',
  states: '离线、AI 失败、会话过期与空态均可恢复。',
}

function showScreen(name) {
  document.querySelectorAll('[data-view]').forEach((view) => {
    view.classList.toggle('active', view.dataset.view === name)
  })
  document.querySelectorAll('.screen-link').forEach((link) => {
    link.classList.toggle('active', link.dataset.screen === name)
  })
  const index = screens.indexOf(name)
  document.querySelector('#flow-index').textContent = `${String(index + 1).padStart(2, '0')} / 07`
  document.querySelector('#flow-description').textContent = descriptions[name]
}

document.querySelectorAll('[data-screen], [data-go]').forEach((button) => {
  button.addEventListener('click', () => showScreen(button.dataset.screen || button.dataset.go))
})

document.querySelector('#login-form').addEventListener('submit', (event) => {
  event.preventDefault()
  showScreen('home')
})

const codeButton = document.querySelector('#code-button')
codeButton.addEventListener('click', () => {
  let seconds = 60
  codeButton.disabled = true
  codeButton.textContent = `${seconds}s`
  const timer = window.setInterval(() => {
    seconds -= 1
    codeButton.textContent = `${seconds}s`
    if (seconds === 0) {
      window.clearInterval(timer)
      codeButton.disabled = false
      codeButton.textContent = '重新获取'
    }
  }, 1000)
})

document.querySelectorAll('#state-grid button').forEach((button) => {
  button.addEventListener('click', () => {
    document.querySelectorAll('#state-grid button').forEach((item) => item.classList.remove('selected'))
    button.classList.add('selected')
  })
})

const content = document.querySelector('#record-content')
const count = document.querySelector('#content-count')
content.addEventListener('input', () => {
  count.textContent = String(content.value.length)
})
count.textContent = String(content.value.length)

document.querySelector('#save-record').addEventListener('click', () => {
  const button = document.querySelector('#save-record')
  button.innerHTML = '正在保存 <span>···</span>'
  button.disabled = true
  window.setTimeout(() => {
    button.innerHTML = '保存这次归零 <span>→</span>'
    button.disabled = false
    showScreen('success')
  }, 650)
})
