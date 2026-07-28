import { useEffect, useState } from 'react'
import {
  Alert,
  Button,
  Card,
  Checkbox,
  Descriptions,
  Drawer,
  Input,
  InputNumber,
  Layout,
  Menu,
  Modal,
  Space,
  Table,
  Tag,
  Typography,
} from 'antd'
import type { ColumnsType } from 'antd/es/table'
import {
  DashboardOutlined,
  BarChartOutlined,
  CustomerServiceOutlined,
  LogoutOutlined,
  MailOutlined,
  MessageOutlined,
  ReloadOutlined,
  SafetyCertificateOutlined,
  SettingOutlined,
  TeamOutlined,
} from '@ant-design/icons'
import SupportPanel from './SupportPanel'
import EvidencePanel from './EvidencePanel'

const { Header, Sider, Content } = Layout

type MenuKey = 'overview' | 'users' | 'support' | 'evidence' | 'prompts' | 'settings'

type PromptTemplateSummary = {
  id: number
  code: string
  name: string
  version: number
  enabled: boolean
  reviewStatus: 'PENDING' | 'APPROVED' | 'REJECTED'
  active: boolean
  createdByUid: string | null
  reviewedByUid: string | null
  reviewedAt: string | null
  createdAt: string
}

type PromptTemplateDetail = PromptTemplateSummary & {
  content: string
  latestEvaluation: PromptEvaluation | null
  audit: PromptAudit[]
}

type PromptAudit = {
  action:
    | 'CREATE'
    | 'REVIEW_APPROVED'
    | 'REVIEW_REJECTED'
    | 'EVALUATION_PASSED'
    | 'EVALUATION_FAILED'
    | 'ACTIVATE'
    | 'ROLLBACK'
  actorUid: string | null
  fromVersion: number | null
  toVersion: number | null
  reasonCode: string
  createdAt: string
}

type PromptEvaluation = {
  id: number
  evaluatorUid: string | null
  corpusVersion: string
  modelAlias: string
  hardFailureCount: number
  safetyScore: number
  consentScore: number
  privacyScore: number
  minimumDimensionScore: number
  averageScore: number
  bilingualReviewed: boolean
  productReviewer: string
  engineeringReviewer: string
  defectCategories: string | null
  passed: boolean
  createdAt: string
}

type PromptTemplateListResponse = {
  items: PromptTemplateSummary[]
}

type AdminSession = {
  accessToken: string
  expiresAt: number
  admin: {
    uid: string
    email: string
  }
}

type AdminAuthResponse = {
  accessToken: string
  expiresIn: number
  admin: {
    uid: string
    email: string
  }
}

const sessionStorageKey = 'zeroon.admin.session'
const deviceStorageKey = 'zeroon.admin.deviceId'

export default function App() {
  const [selectedKey, setSelectedKey] = useState<MenuKey>('overview')
  const [session, setSession] = useState<AdminSession | null>(() => restoreSession())

  useEffect(() => {
    if (!session) return
    const remaining = session.expiresAt - Date.now()
    if (remaining <= 0) {
      clearSession()
      setSession(null)
      return
    }
    const timer = window.setTimeout(() => {
      clearSession()
      setSession(null)
    }, remaining)
    return () => window.clearTimeout(timer)
  }, [session])

  function acceptSession(next: AdminSession) {
    sessionStorage.setItem(sessionStorageKey, JSON.stringify(next))
    setSession(next)
  }

  function endSession() {
    clearSession()
    setSession(null)
  }

  if (!session) {
    return <AdminLogin onAuthenticated={acceptSession} />
  }

  return (
    <Layout className="shell">
      <Sider breakpoint="lg" collapsedWidth="0" theme="dark">
        <div className="brand">ZEROON</div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[selectedKey]}
          onClick={(event) => setSelectedKey(event.key as MenuKey)}
          items={[
            { key: 'overview', icon: <DashboardOutlined />, label: '概览' },
            { key: 'users', icon: <TeamOutlined />, label: '用户' },
            { key: 'support', icon: <CustomerServiceOutlined />, label: '用户支持' },
            { key: 'evidence', icon: <BarChartOutlined />, label: 'Beta 证据' },
            { key: 'prompts', icon: <MessageOutlined />, label: 'Prompt' },
            { key: 'settings', icon: <SettingOutlined />, label: '系统配置' },
          ]}
        />
        </Sider>
      <Layout>
        <Header className="header">
          <Space className="header-title">
            <Typography.Text strong className="header-name">
              <span className="header-name-full">ZEROON 管理后台</span>
              <span className="header-name-compact">ZEROON</span>
            </Typography.Text>
            <Tag color="cyan">受控会话</Tag>
          </Space>
          <Space className="header-session">
            <Typography.Text type="secondary" className="header-email">
              {session.admin.email}
            </Typography.Text>
            <Button type="text" icon={<LogoutOutlined />} onClick={endSession}>
              退出
            </Button>
          </Space>
        </Header>
        <Content className="content">
          {selectedKey === 'support' ? (
            <SupportPanel token={session.accessToken} onSessionExpired={endSession} />
          ) : selectedKey === 'evidence' ? (
            <EvidencePanel token={session.accessToken} onSessionExpired={endSession} />
          ) : selectedKey === 'prompts' ? (
            <PromptTemplatesPanel
              token={session.accessToken}
              onSessionExpired={endSession}
            />
          ) : (
            <OverviewPanel />
          )}
        </Content>
      </Layout>
    </Layout>
  )
}

function AdminLogin({ onAuthenticated }: { onAuthenticated: (session: AdminSession) => void }) {
  const [email, setEmail] = useState('')
  const [code, setCode] = useState('')
  const [codeSent, setCodeSent] = useState(false)
  const [sending, setSending] = useState(false)
  const [loggingIn, setLoggingIn] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function requestCode() {
    if (!email.trim()) {
      setError('请输入管理员邮箱。')
      return
    }
    setSending(true)
    setError(null)
    try {
      const response = await fetch('/api/v1/admin/auth/email/codes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: email.trim() }),
      })
      if (!response.ok) {
        throw new Error(await authError(response, '验证码暂时无法发送，请稍后再试。'))
      }
      setCodeSent(true)
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : '验证码暂时无法发送，请稍后再试。')
    } finally {
      setSending(false)
    }
  }

  async function login() {
    if (!email.trim() || !/^\d{6}$/.test(code)) {
      setError('请输入管理员邮箱和六位验证码。')
      return
    }
    setLoggingIn(true)
    setError(null)
    try {
      const response = await fetch('/api/v1/admin/auth/email/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: email.trim(),
          code,
          deviceId: adminDeviceId(),
        }),
      })
      if (!response.ok) {
        throw new Error(await authError(response, '邮箱或验证码不正确，或该邮箱未获授权。'))
      }
      const result = (await response.json()) as AdminAuthResponse
      onAuthenticated({
        accessToken: result.accessToken,
        expiresAt: Date.now() + result.expiresIn * 1000,
        admin: result.admin,
      })
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : '登录失败，请稍后再试。')
    } finally {
      setLoggingIn(false)
    }
  }

  return (
    <main className="admin-login-shell">
      <Card className="admin-login-card" variant="borderless">
        <Space direction="vertical" size="large" className="full-width">
          <div className="admin-login-brand">ZEROON</div>
          <div>
            <Typography.Title level={2}>管理后台</Typography.Title>
            <Typography.Paragraph type="secondary">
              仅限预先授权的运营与支持人员。登录不会创建或进入普通 App 账号。
            </Typography.Paragraph>
          </div>
          <Alert
            type="info"
            showIcon
            icon={<SafetyCertificateOutlined />}
            message="短时受控会话"
            description="验证码仅用于本次后台登录；会话保存在当前标签页，30 分钟后自动结束。"
          />
          <Input
            size="large"
            prefix={<MailOutlined />}
            type="email"
            autoComplete="email"
            placeholder="管理员邮箱"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            onPressEnter={() => void requestCode()}
          />
          {codeSent ? (
            <>
              <Input
                size="large"
                inputMode="numeric"
                autoComplete="one-time-code"
                maxLength={6}
                placeholder="六位验证码"
                value={code}
                onChange={(event) => setCode(event.target.value.replace(/\D/g, ''))}
                onPressEnter={() => void login()}
              />
              <Typography.Text type="secondary">
                如果该邮箱已获授权，验证码已发送。未收到时可稍后重新获取。
              </Typography.Text>
            </>
          ) : null}
          {error ? <Alert type="warning" showIcon message={error} /> : null}
          <Space className="admin-login-actions">
            <Button size="large" loading={sending} onClick={() => void requestCode()}>
              {codeSent ? '重新获取' : '获取验证码'}
            </Button>
            <Button
              size="large"
              type="primary"
              disabled={!codeSent}
              loading={loggingIn}
              onClick={() => void login()}
            >
              进入后台
            </Button>
          </Space>
        </Space>
      </Card>
    </main>
  )
}

function restoreSession(): AdminSession | null {
  try {
    const stored = sessionStorage.getItem(sessionStorageKey)
    if (!stored) return null
    const session = JSON.parse(stored) as AdminSession
    if (
      !session.accessToken ||
      !session.admin?.email ||
      !Number.isFinite(session.expiresAt) ||
      session.expiresAt <= Date.now()
    ) {
      clearSession()
      return null
    }
    return session
  } catch {
    clearSession()
    return null
  }
}

function clearSession() {
  sessionStorage.removeItem(sessionStorageKey)
}

function adminDeviceId() {
  const stored = sessionStorage.getItem(deviceStorageKey)
  if (stored) return stored
  const next = `admin-web-${crypto.randomUUID()}`
  sessionStorage.setItem(deviceStorageKey, next)
  return next
}

async function authError(response: Response, fallback: string) {
  if (response.status === 429) return '操作过于频繁，请稍后再试。'
  if (response.status === 401 || response.status === 403) return fallback
  try {
    const body = (await response.json()) as { message?: string }
    return body.message || fallback
  } catch {
    return fallback
  }
}

function OverviewPanel() {
  return (
    <section className="panel">
      <Typography.Title level={2}>研发基线已建立</Typography.Title>
      <Typography.Paragraph>
        当前 Sprint 12 已接入人工支持、Prompt 模板与 Beta 聚合证据的只读管理。运营视图使用
        独立的 ADMIN 权限，并对小样本结果执行服务端隐私抑制。
      </Typography.Paragraph>
    </section>
  )
}

function PromptTemplatesPanel({
  token,
  onSessionExpired,
}: {
  token: string
  onSessionExpired: () => void
}) {
  const [items, setItems] = useState<PromptTemplateSummary[]>([])
  const [selectedPrompt, setSelectedPrompt] = useState<PromptTemplateDetail | null>(null)
  const [loading, setLoading] = useState(false)
  const [detailLoading, setDetailLoading] = useState(false)
  const [mutationLoading, setMutationLoading] = useState(false)
  const [createOpen, setCreateOpen] = useState(false)
  const [createName, setCreateName] = useState('')
  const [createContent, setCreateContent] = useState('')
  const [createReason, setCreateReason] = useState('PERSONA_VERSION_CREATE')
  const [actionReason, setActionReason] = useState('')
  const [evaluationOpen, setEvaluationOpen] = useState(false)
  const [corpusVersion, setCorpusVersion] = useState('PERSONA_V2_V1')
  const [modelAlias, setModelAlias] = useState('RELEASE_MODEL')
  const [hardFailureCount, setHardFailureCount] = useState(0)
  const [safetyScore, setSafetyScore] = useState(2)
  const [consentScore, setConsentScore] = useState(2)
  const [privacyScore, setPrivacyScore] = useState(2)
  const [minimumDimensionScore, setMinimumDimensionScore] = useState(1)
  const [averageScore, setAverageScore] = useState(1.75)
  const [bilingualReviewed, setBilingualReviewed] = useState(false)
  const [productReviewer, setProductReviewer] = useState('')
  const [engineeringReviewer, setEngineeringReviewer] = useState('')
  const [defectCategories, setDefectCategories] = useState('')
  const [error, setError] = useState<string | null>(null)

  const columns: ColumnsType<PromptTemplateSummary> = [
      {
        title: 'Code',
        dataIndex: 'code',
        key: 'code',
      },
      {
        title: '名称',
        dataIndex: 'name',
        key: 'name',
      },
      {
        title: '版本',
        dataIndex: 'version',
        key: 'version',
        width: 96,
        render: (version: number) => <Tag color="blue">v{version}</Tag>,
      },
      {
        title: '状态',
        key: 'status',
        width: 176,
        render: (_, record) => (
          <Space size={4} wrap>
            <Tag
              color={
                record.reviewStatus === 'APPROVED'
                  ? 'green'
                  : record.reviewStatus === 'REJECTED'
                    ? 'red'
                    : 'gold'
              }
            >
              {reviewStatusLabel(record.reviewStatus)}
            </Tag>
            {record.active ? <Tag color="cyan">运行中</Tag> : null}
          </Space>
        ),
      },
      {
        title: '创建时间',
        dataIndex: 'createdAt',
        key: 'createdAt',
        render: (value: string) => new Date(value).toLocaleString(),
      },
      {
        title: '操作',
        key: 'action',
        width: 96,
        render: (_, record) => (
          <Button type="link" onClick={() => loadDetail(record.id)}>
            查看
          </Button>
        ),
      },
    ]

  async function loadPrompts() {
    setLoading(true)
    setError(null)
    try {
      const response = await fetch('/api/v1/admin/prompts', {
        headers: { Authorization: `Bearer ${token}` },
      })
      if (response.status === 401) onSessionExpired()
      if (!response.ok) {
        throw new Error(`读取失败：${response.status}`)
      }
      const data = (await response.json()) as PromptTemplateListResponse
      setItems(data.items)
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : '读取失败')
    } finally {
      setLoading(false)
    }
  }

  async function loadDetail(promptId: number) {
    setDetailLoading(true)
    setError(null)
    try {
      const response = await fetch(`/api/v1/admin/prompts/${promptId}`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      if (response.status === 401) onSessionExpired()
      if (!response.ok) {
        throw new Error(`详情读取失败：${response.status}`)
      }
      const data = (await response.json()) as PromptTemplateDetail
      setSelectedPrompt(data)
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : '详情读取失败')
    } finally {
      setDetailLoading(false)
    }
  }

  async function createPrompt() {
    if (!createName.trim() || !createContent.trim() || !createReason.trim()) {
      setError('名称、Prompt 内容和原因码不能为空。')
      return
    }
    setMutationLoading(true)
    setError(null)
    try {
      const response = await fetch('/api/v1/admin/prompts', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          code: 'COMPANION_REFLECTION',
          name: createName.trim(),
          content: createContent.trim(),
          reasonCode: createReason.trim(),
        }),
      })
      if (response.status === 401) onSessionExpired()
      if (!response.ok) {
        throw new Error(await mutationError(response, '创建失败'))
      }
      const created = (await response.json()) as PromptTemplateDetail
      setCreateOpen(false)
      setCreateName('')
      setCreateContent('')
      setSelectedPrompt(created)
      await loadPrompts()
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : '创建失败')
    } finally {
      setMutationLoading(false)
    }
  }

  async function reviewPrompt(decision: 'APPROVE' | 'REJECT') {
    if (!selectedPrompt || !actionReason.trim()) {
      setError('审核前请填写原因码。')
      return
    }
    await mutatePrompt(
      `/api/v1/admin/prompts/${selectedPrompt.id}/review`,
      { decision, reasonCode: actionReason.trim() },
      '审核失败',
    )
  }

  async function recordEvaluation() {
    if (
      !selectedPrompt ||
      !corpusVersion.trim() ||
      !modelAlias.trim() ||
      !productReviewer.trim() ||
      !engineeringReviewer.trim() ||
      !actionReason.trim()
    ) {
      setError('请填写语料版本、模型别名、两位评测人和原因码。')
      return
    }
    await mutatePrompt(
      `/api/v1/admin/prompts/${selectedPrompt.id}/evaluations`,
      {
        corpusVersion: corpusVersion.trim().toUpperCase(),
        modelAlias: modelAlias.trim().toUpperCase(),
        hardFailureCount,
        safetyScore,
        consentScore,
        privacyScore,
        minimumDimensionScore,
        averageScore,
        bilingualReviewed,
        productReviewer: productReviewer.trim(),
        engineeringReviewer: engineeringReviewer.trim(),
        defectCategories: defectCategories.trim() || null,
        reasonCode: actionReason.trim(),
      },
      '评测记录失败',
    )
    setEvaluationOpen(false)
  }

  function confirmActivation() {
    if (!selectedPrompt || !actionReason.trim()) {
      setError('启用或回滚前请填写原因码。')
      return
    }
    const activeVersion = items.find(
      (item) => item.code === selectedPrompt.code && item.active,
    )?.version
    const rollback = activeVersion !== undefined && selectedPrompt.version < activeVersion
    Modal.confirm({
      title: rollback ? `回滚到 v${selectedPrompt.version}？` : `启用 v${selectedPrompt.version}？`,
      content: rollback
        ? '运行时将立即改用这个已审核的旧版本，并留下回滚审计。'
        : '运行时将立即改用这个已审核版本。',
      okText: rollback ? '确认回滚' : '确认启用',
      cancelText: '取消',
      onOk: () =>
        mutatePrompt(
          `/api/v1/admin/prompts/${selectedPrompt.id}/activate`,
          { reasonCode: actionReason.trim() },
          rollback ? '回滚失败' : '启用失败',
        ),
    })
  }

  async function mutatePrompt(path: string, body: object, fallback: string) {
    setMutationLoading(true)
    setError(null)
    try {
      const response = await fetch(path, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(body),
      })
      if (response.status === 401) onSessionExpired()
      if (!response.ok) {
        throw new Error(await mutationError(response, fallback))
      }
      const updated = (await response.json()) as PromptTemplateDetail
      setSelectedPrompt(updated)
      setActionReason('')
      await loadPrompts()
    } catch (caught) {
      setError(caught instanceof Error ? caught.message : fallback)
    } finally {
      setMutationLoading(false)
    }
  }

  return (
    <section className="panel prompt-panel">
      <Space direction="vertical" size="large" className="full-width">
        <div>
          <Typography.Title level={2}>Prompt 模板</Typography.Title>
          <Typography.Paragraph>
            Prompt 内容创建后不可修改。新版本需要另一名管理员审核，明确启用后才进入运行时；
            启用旧版本会记录为回滚。
          </Typography.Paragraph>
        </div>

        <Card>
          <Space className="full-width" wrap>
            <Button icon={<ReloadOutlined />} onClick={loadPrompts}>
              刷新
            </Button>
            <Button type="primary" onClick={() => setCreateOpen(true)}>
              新建版本
            </Button>
          </Space>
        </Card>

        {error ? <Alert type="warning" showIcon message={error} /> : null}

        <Table
          rowKey="id"
          loading={loading}
          columns={columns}
          dataSource={items}
          pagination={false}
        />
      </Space>

      <Drawer
        title="Prompt 详情"
        open={selectedPrompt !== null || detailLoading}
        width={720}
        onClose={() => setSelectedPrompt(null)}
      >
        {selectedPrompt ? (
          <Space direction="vertical" size="large" className="full-width">
            <Descriptions bordered column={1} size="small">
              <Descriptions.Item label="Code">{selectedPrompt.code}</Descriptions.Item>
              <Descriptions.Item label="名称">{selectedPrompt.name}</Descriptions.Item>
              <Descriptions.Item label="版本">v{selectedPrompt.version}</Descriptions.Item>
              <Descriptions.Item label="状态">
                {reviewStatusLabel(selectedPrompt.reviewStatus)}
                {selectedPrompt.active ? ' · 运行中' : ''}
              </Descriptions.Item>
              <Descriptions.Item label="创建人">
                {selectedPrompt.createdByUid ?? '历史版本'}
              </Descriptions.Item>
              <Descriptions.Item label="审核人">
                {selectedPrompt.reviewedByUid ?? '尚未审核'}
              </Descriptions.Item>
              <Descriptions.Item label="创建时间">
                {new Date(selectedPrompt.createdAt).toLocaleString()}
              </Descriptions.Item>
            </Descriptions>
            <Typography.Title level={4}>内容</Typography.Title>
            <pre className="prompt-content">{selectedPrompt.content}</pre>
            <Card size="small" title="最新 Persona 评测">
              {selectedPrompt.latestEvaluation ? (
                <Descriptions column={2} size="small">
                  <Descriptions.Item label="门禁">
                    <Tag color={selectedPrompt.latestEvaluation.passed ? 'green' : 'red'}>
                      {selectedPrompt.latestEvaluation.passed ? '通过' : '未通过'}
                    </Tag>
                  </Descriptions.Item>
                  <Descriptions.Item label="语料">
                    {selectedPrompt.latestEvaluation.corpusVersion}
                  </Descriptions.Item>
                  <Descriptions.Item label="模型别名">
                    {selectedPrompt.latestEvaluation.modelAlias}
                  </Descriptions.Item>
                  <Descriptions.Item label="平均分">
                    {selectedPrompt.latestEvaluation.averageScore}
                  </Descriptions.Item>
                  <Descriptions.Item label="硬失败">
                    {selectedPrompt.latestEvaluation.hardFailureCount}
                  </Descriptions.Item>
                  <Descriptions.Item label="双语复核">
                    {selectedPrompt.latestEvaluation.bilingualReviewed ? '是' : '否'}
                  </Descriptions.Item>
                  <Descriptions.Item label="产品评测人">
                    {selectedPrompt.latestEvaluation.productReviewer}
                  </Descriptions.Item>
                  <Descriptions.Item label="工程评测人">
                    {selectedPrompt.latestEvaluation.engineeringReviewer}
                  </Descriptions.Item>
                </Descriptions>
              ) : (
                <Typography.Text type="secondary">尚无评测记录，不能前向启用。</Typography.Text>
              )}
            </Card>
            <Card size="small" title="受控操作">
              <Space direction="vertical" className="full-width">
                <Input
                  placeholder="原因码，例如 PERSONA_V2_APPROVAL"
                  value={actionReason}
                  onChange={(event) => setActionReason(event.target.value.toUpperCase())}
                />
                <Space wrap>
                  {selectedPrompt.reviewStatus === 'PENDING' ? (
                    <>
                      <Button
                        type="primary"
                        loading={mutationLoading}
                        onClick={() => reviewPrompt('APPROVE')}
                      >
                        审核通过
                      </Button>
                      <Button
                        danger
                        loading={mutationLoading}
                        onClick={() => reviewPrompt('REJECT')}
                      >
                        审核拒绝
                      </Button>
                    </>
                  ) : null}
                  {selectedPrompt.reviewStatus === 'APPROVED' && !selectedPrompt.active ? (
                    <>
                      <Button onClick={() => setEvaluationOpen(true)}>记录评测结果</Button>
                      <Button
                        type="primary"
                        loading={mutationLoading}
                        disabled={
                          !selectedPrompt.latestEvaluation?.passed &&
                          !isRollback(selectedPrompt, items)
                        }
                        onClick={confirmActivation}
                      >
                        启用或回滚到此版本
                      </Button>
                    </>
                  ) : null}
                </Space>
              </Space>
            </Card>
            <Typography.Title level={4}>审计记录</Typography.Title>
            <Space direction="vertical" className="full-width">
              {selectedPrompt.audit.map((entry, index) => (
                <Card key={`${entry.createdAt}-${index}`} size="small">
                  <Space wrap>
                    <Tag>{auditActionLabel(entry.action)}</Tag>
                    <Typography.Text>{entry.actorUid ?? '系统迁移'}</Typography.Text>
                    <Typography.Text code>{entry.reasonCode}</Typography.Text>
                    <Typography.Text type="secondary">
                      {new Date(entry.createdAt).toLocaleString()}
                    </Typography.Text>
                  </Space>
                </Card>
              ))}
            </Space>
          </Space>
        ) : (
          <Typography.Text>正在读取详情...</Typography.Text>
        )}
      </Drawer>

      <Modal
        title="新建 Prompt 版本"
        open={createOpen}
        okText="创建待审核版本"
        cancelText="取消"
        confirmLoading={mutationLoading}
        onOk={createPrompt}
        onCancel={() => setCreateOpen(false)}
        width={760}
      >
        <Space direction="vertical" className="full-width">
          <Alert
            type="info"
            showIcon
            message="新版本不会自动启用，且必须由另一名管理员审核。"
          />
          <Input value="COMPANION_REFLECTION" disabled addonBefore="Code" />
          <Input
            placeholder="版本名称"
            value={createName}
            onChange={(event) => setCreateName(event.target.value)}
          />
          <Input
            placeholder="创建原因码"
            value={createReason}
            onChange={(event) => setCreateReason(event.target.value.toUpperCase())}
          />
          <Input.TextArea
            rows={16}
            placeholder="完整 Prompt 内容"
            value={createContent}
            onChange={(event) => setCreateContent(event.target.value)}
          />
        </Space>
      </Modal>

      <Modal
        title="记录 Persona 评测"
        open={evaluationOpen}
        okText="记录并计算门禁"
        cancelText="取消"
        confirmLoading={mutationLoading}
        onOk={recordEvaluation}
        onCancel={() => setEvaluationOpen(false)}
        width={720}
      >
        <Space direction="vertical" className="full-width">
          <Alert
            type="warning"
            showIcon
            message="这里只记录合成语料的汇总分数和缺陷分类，不要粘贴用户内容、测试输入或模型回复。"
          />
          <Input
            addonBefore="语料版本"
            value={corpusVersion}
            onChange={(event) => setCorpusVersion(event.target.value)}
          />
          <Input
            addonBefore="模型别名"
            value={modelAlias}
            onChange={(event) => setModelAlias(event.target.value)}
          />
          <Space wrap>
            <InputNumber
              addonBefore="硬失败"
              min={0}
              value={hardFailureCount}
              onChange={(value) => setHardFailureCount(value ?? 0)}
            />
            <InputNumber
              addonBefore="安全"
              min={0}
              max={2}
              value={safetyScore}
              onChange={(value) => setSafetyScore(value ?? 0)}
            />
            <InputNumber
              addonBefore="同意"
              min={0}
              max={2}
              value={consentScore}
              onChange={(value) => setConsentScore(value ?? 0)}
            />
            <InputNumber
              addonBefore="隐私"
              min={0}
              max={2}
              value={privacyScore}
              onChange={(value) => setPrivacyScore(value ?? 0)}
            />
            <InputNumber
              addonBefore="最低维度"
              min={0}
              max={2}
              value={minimumDimensionScore}
              onChange={(value) => setMinimumDimensionScore(value ?? 0)}
            />
            <InputNumber
              addonBefore="平均分"
              min={0}
              max={2}
              step={0.01}
              value={averageScore}
              onChange={(value) => setAverageScore(value ?? 0)}
            />
          </Space>
          <Checkbox
            checked={bilingualReviewed}
            onChange={(event) => setBilingualReviewed(event.target.checked)}
          >
            中文与英文均已完成评测
          </Checkbox>
          <Input
            addonBefore="产品评测人"
            value={productReviewer}
            onChange={(event) => setProductReviewer(event.target.value)}
          />
          <Input
            addonBefore="工程评测人"
            value={engineeringReviewer}
            onChange={(event) => setEngineeringReviewer(event.target.value)}
          />
          <Input
            addonBefore="缺陷分类"
            placeholder="仅填内容无关的分类码，例如 STYLE_MINOR"
            value={defectCategories}
            onChange={(event) => setDefectCategories(event.target.value.toUpperCase())}
          />
          <Input
            addonBefore="原因码"
            placeholder="例如 PERSONA_V2_EVALUATION"
            value={actionReason}
            onChange={(event) => setActionReason(event.target.value.toUpperCase())}
          />
        </Space>
      </Modal>
    </section>
  )
}

function reviewStatusLabel(status: PromptTemplateSummary['reviewStatus']) {
  if (status === 'APPROVED') return '已审核'
  if (status === 'REJECTED') return '已拒绝'
  return '待审核'
}

function auditActionLabel(action: PromptAudit['action']) {
  const labels: Record<PromptAudit['action'], string> = {
    CREATE: '创建',
    REVIEW_APPROVED: '审核通过',
    REVIEW_REJECTED: '审核拒绝',
    EVALUATION_PASSED: '评测通过',
    EVALUATION_FAILED: '评测未通过',
    ACTIVATE: '启用',
    ROLLBACK: '回滚',
  }
  return labels[action]
}

function isRollback(
  selectedPrompt: PromptTemplateDetail,
  items: PromptTemplateSummary[],
) {
  const activeVersion = items.find(
    (item) => item.code === selectedPrompt.code && item.active,
  )?.version
  return activeVersion !== undefined && selectedPrompt.version < activeVersion
}

async function mutationError(response: Response, fallback: string) {
  try {
    const body = (await response.json()) as { message?: string }
    return body.message ?? `${fallback}：${response.status}`
  } catch {
    return `${fallback}：${response.status}`
  }
}
