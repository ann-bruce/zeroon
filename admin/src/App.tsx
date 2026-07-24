import { useEffect, useMemo, useState } from 'react'
import {
  Alert,
  Button,
  Card,
  Descriptions,
  Drawer,
  Input,
  Layout,
  Menu,
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
  MessageOutlined,
  ReloadOutlined,
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
  createdAt: string
}

type PromptTemplateDetail = PromptTemplateSummary & {
  content: string
}

type PromptTemplateListResponse = {
  items: PromptTemplateSummary[]
}

const tokenStorageKey = 'zeroon.admin.accessToken'

export default function App() {
  const [selectedKey, setSelectedKey] = useState<MenuKey>('overview')

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
          <Space>
            <Typography.Text strong>ZEROON 管理后台</Typography.Text>
            <Tag color="cyan">Sprint 12</Tag>
          </Space>
        </Header>
        <Content className="content">
          {selectedKey === 'support' ? (
            <SupportPanel />
          ) : selectedKey === 'evidence' ? (
            <EvidencePanel />
          ) : selectedKey === 'prompts' ? (
            <PromptTemplatesPanel />
          ) : (
            <OverviewPanel />
          )}
        </Content>
      </Layout>
    </Layout>
  )
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

function PromptTemplatesPanel() {
  const [token, setToken] = useState(() => localStorage.getItem(tokenStorageKey) ?? '')
  const [items, setItems] = useState<PromptTemplateSummary[]>([])
  const [selectedPrompt, setSelectedPrompt] = useState<PromptTemplateDetail | null>(null)
  const [loading, setLoading] = useState(false)
  const [detailLoading, setDetailLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const columns = useMemo<ColumnsType<PromptTemplateSummary>>(
    () => [
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
        dataIndex: 'enabled',
        key: 'enabled',
        width: 96,
        render: (enabled: boolean) => (
          <Tag color={enabled ? 'green' : 'default'}>{enabled ? '启用' : '停用'}</Tag>
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
    ],
    [token],
  )

  useEffect(() => {
    if (token) {
      void loadPrompts()
    }
  }, [])

  async function loadPrompts() {
    if (!token.trim()) {
      setError('请先填写访问令牌。')
      return
    }
    localStorage.setItem(tokenStorageKey, token.trim())
    setLoading(true)
    setError(null)
    try {
      const response = await fetch('/api/v1/admin/prompts', {
        headers: { Authorization: `Bearer ${token.trim()}` },
      })
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
        headers: { Authorization: `Bearer ${token.trim()}` },
      })
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

  return (
    <section className="panel prompt-panel">
      <Space direction="vertical" size="large" className="full-width">
        <div>
          <Typography.Title level={2}>Prompt 模板</Typography.Title>
          <Typography.Paragraph>
            只读查看当前后端 Prompt 模板版本。这里不提供编辑入口，避免绕过版本化和审计。
          </Typography.Paragraph>
        </div>

        <Card>
          <Space.Compact className="token-input">
            <Input.Password
              placeholder="粘贴后台访问令牌"
              value={token}
              onChange={(event) => setToken(event.target.value)}
            />
            <Button icon={<ReloadOutlined />} type="primary" onClick={loadPrompts}>
              读取
            </Button>
          </Space.Compact>
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
                {selectedPrompt.enabled ? '启用' : '停用'}
              </Descriptions.Item>
              <Descriptions.Item label="创建时间">
                {new Date(selectedPrompt.createdAt).toLocaleString()}
              </Descriptions.Item>
            </Descriptions>
            <Typography.Title level={4}>内容</Typography.Title>
            <pre className="prompt-content">{selectedPrompt.content}</pre>
          </Space>
        ) : (
          <Typography.Text>正在读取详情...</Typography.Text>
        )}
      </Drawer>
    </section>
  )
}
